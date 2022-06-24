import Retry
import os.log
import Models
import Shared
import Combine
import Defaults
import XXModels
import XXDatabase
import Foundation
import ToastFeature
import BackupFeature
import NetworkMonitor
import DependencyInjection
import XXLegacyDatabaseMigrator

let logHandler = OSLog(subsystem: "xx.network", category: "Performance debugging")

struct BackupParameters: Codable {
    var email: String?
    var phone: String?
    var username: String
}

struct BackupReport: Codable {
    var contactIds: [String]
    var parameters: String

    private enum CodingKeys: String, CodingKey {
        case parameters = "Params"
        case contactIds = "RestoredContacts"
    }
}

public final class Session: SessionType {
    @KeyObject(.theme, defaultValue: nil) var theme: String?
    @KeyObject(.email, defaultValue: nil) var email: String?
    @KeyObject(.phone, defaultValue: nil) var phone: String?
    @KeyObject(.avatar, defaultValue: nil) var avatar: Data?
    @KeyObject(.username, defaultValue: nil) var username: String?
    @KeyObject(.biometrics, defaultValue: false) var biometrics: Bool
    @KeyObject(.hideAppList, defaultValue: false) var hideAppList: Bool
    @KeyObject(.requestCounter, defaultValue: 0) var requestCounter: Int
    @KeyObject(.sharingEmail, defaultValue: false) var isSharingEmail: Bool
    @KeyObject(.sharingPhone, defaultValue: false) var isSharingPhone: Bool
    @KeyObject(.recordingLogs, defaultValue: true) var recordingLogs: Bool
    @KeyObject(.crashReporting, defaultValue: true) var crashReporting: Bool
    @KeyObject(.icognitoKeyboard, defaultValue: false) var icognitoKeyboard: Bool
    @KeyObject(.pushNotifications, defaultValue: false) var pushNotifications: Bool
    @KeyObject(.inappnotifications, defaultValue: true) var inappnotifications: Bool

    @Dependency var backupService: BackupService
    @Dependency var toastController: ToastController
    @Dependency var networkMonitor: NetworkMonitoring

    public let client: Client
    public let dbManager: Database
    private var cancellables = Set<AnyCancellable>()

    public var myId: Data { client.bindings.myId }
    public var version: String { type(of: client.bindings).version }

    public var myQR: Data {
        client
            .bindings
            .meMarshalled(
                username!,
                email: isSharingEmail ? email : nil,
                phone: isSharingPhone ? phone : nil
            )
    }

    public var hasRunningTasks: Bool {
        client.bindings.hasRunningTasks
    }

    public var isOnline: AnyPublisher<Bool, Never> {
        networkMonitor.statusPublisher.map { $0 == .available }.eraseToAnyPublisher()
    }

    public init(
        passphrase: String,
        backupFile: Data,
        ndf: String
    ) throws {
        let network = try! DependencyInjection.Container.shared.resolve() as XXNetworking

        os_signpost(.begin, log: logHandler, name: "Decrypting", "Calling newClientFromBackup")
        let (client, backupData) = try network.newClientFromBackup(passphrase: passphrase, data: backupFile, ndf: ndf)
        os_signpost(.end, log: logHandler, name: "Decrypting", "Finished newClientFromBackup")

        self.client = client

        let oldPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        )[0].appending("/xxmessenger.sqlite")

        let newPath = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.elixxir.messenger")!
            .appendingPathComponent("database")
            .appendingPathExtension("sqlite").path

        try Migrator.live()(
            try .init(path: oldPath),
            to: try .onDisk(path: newPath),
            myContactId: client.bindings.myId,
            meMarshaled: client.bindings.meMarshalled
        )

        dbManager = try Database.onDisk(path: newPath)

        let report = try! JSONDecoder().decode(BackupReport.self, from: backupData!)

        if !report.parameters.isEmpty {
            let params = try! JSONDecoder().decode(BackupParameters.self, from: Data(report.parameters.utf8))

            username = params.username
            phone = params.phone
            email = params.email
        }

        try continueInitialization()

        if !report.contactIds.isEmpty {
            client.restoreContacts(fromBackup: try! JSONSerialization.data(withJSONObject: report.contactIds))
        }
    }

    public init(ndf: String) throws {
        let network = try! DependencyInjection.Container.shared.resolve() as XXNetworking
        self.client = try network.newClient(ndf: ndf)

        let oldPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        )[0].appending("/xxmessenger.sqlite")

        let newPath = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.elixxir.messenger")!
            .appendingPathComponent("database")
            .appendingPathExtension("sqlite").path

        try Migrator.live()(
            try .init(path: oldPath),
            to: try .onDisk(path: newPath),
            myContactId: client.bindings.myId,
            meMarshaled: client.bindings.meMarshalled
        )

        dbManager = try Database.onDisk(path: newPath)

        try continueInitialization()
    }

    private func continueInitialization() throws {
        setupBindings()
        networkMonitor.start()

        networkMonitor.statusPublisher
            .filter { $0 == .available }.first()
            .sink { [unowned self] _ in client.bindings.replayRequests() }
            .store(in: &cancellables)

        registerUnfinishedTransfers()

        let query = Contact.Query(authStatus: [.verificationInProgress])
        _ = try? dbManager.bulkUpdateContacts(query, .init(authStatus: .verificationFailed))
    }

    public func setDummyTraffic(status: Bool) {
        client.dummyManager?.setStatus(status: status)
    }

    public func deleteMyself() throws {
        guard let username = username, let ud = client.userDiscovery else { return }

        try? unregisterNotifications()
        try ud.deleteMyself(username)

        stop()
        cleanUp()
    }

    private func cleanUp() {
        retry(max: 10, retryStrategy: .delay(seconds: 1)) { [unowned self] in
            guard self.hasRunningTasks == false else { throw NSError.create("") }
        }.finalCatch { _ in fatalError("Couldn't delete account because network is not stopping") }

        try! dbManager.drop()
        FileManager.xxCleanup()

        email = nil
        phone = nil
        theme = nil
        avatar = nil
        self.username = nil
        isSharingEmail = false
        isSharingPhone = false
        requestCounter = 0
        biometrics = false
        hideAppList = false
        recordingLogs = true
        crashReporting = true
        icognitoKeyboard = false
        pushNotifications = false
        inappnotifications = true
    }

    private func registerUnfinishedTransfers() {
        guard let unfinishedSendingMessages = try? dbManager.fetchMessages(.init(status: [.sending])),
              let unfinishedSendingTransfers = try? dbManager.fetchFileTransfers(.init(
                id: Set(unfinishedSendingMessages
                    .filter { $0.fileTransferId != nil }
                    .compactMap(\.fileTransferId))))
        else { return }

        // What would be a good way to do this?

        let pairs = unfinishedSendingMessages.map { message -> (Message, FileTransfer) in
            let transfer = unfinishedSendingTransfers.first { ft in
                ft.id == message.fileTransferId
            }

            return (message, transfer!)
        }

        pairs.forEach { message, transfer in
            var message = message
            var transfer = transfer

            do {
                try client.transferManager?.listenUploadFromTransfer(with: transfer.id) { completed, sent, arrived, total, error in
                    if completed {
                        transfer.progress = 1.0
                        message.status = .sent

                    } else {
                        if error != nil {
                            message.status = .sendingFailed
                        } else {
                            transfer.progress = Float(arrived)/Float(total)
                        }
                    }

                    _ = try? self.dbManager.saveFileTransfer(transfer)
                    _ = try? self.dbManager.saveMessage(message)
                }
            } catch {
                message.status = .sendingFailed
                _ = try? self.dbManager.saveMessage(message)
            }
        }
    }

    func updateFactsOnBackup() {
        struct BackupParameters: Codable {
            var email: String?
            var phone: String?
            var username: String

            var jsonFormat: String {
                let data = try! JSONEncoder().encode(self)
                let json = String(data: data, encoding: .utf8)
                return json!
            }
        }

        let params = BackupParameters(
            email: email,
            phone: phone,
            username: username!
        ).jsonFormat

        client.addJson(params)
        backupService.performBackupIfAutomaticIsEnabled()
    }

    private func setupBindings() {
        client.requests
            .sink { [unowned self] in
                if let _ = try? dbManager.fetchContacts(.init(id: [$0.id])).first {
                    return
                }

                if self.inappnotifications {
                    DeviceFeedback.sound(.contactAdded)
                    DeviceFeedback.shake(.notification)
                }

                verify(contact: $0)
            }.store(in: &cancellables)

        client.requestsSent
            .sink { [unowned self] in _ = try? dbManager.saveContact($0) }
            .store(in: &cancellables)

        client.backup
            .throttle(for: .seconds(5), scheduler: DispatchQueue.main, latest: true)
            .sink { [unowned self] in backupService.updateBackup(data: $0) }
            .store(in: &cancellables)

        client.resets
            .sink { [unowned self] in
                /// This will get called when my contact restore its contact.
                /// TODO: Hold a record on the chat that this contact restored.
                ///
                var contact = $0
                contact.authStatus = .friend
                _ = try? dbManager.saveContact(contact)
            }.store(in: &cancellables)

        backupService.settingsPublisher
            .map { $0.enabledService != nil }
            .removeDuplicates()
            .sink { [unowned self] in
                if $0 == true {
                    guard let passphrase = backupService.passphrase else {
                        client.resumeBackup()
                        updateFactsOnBackup()
                        return
                    }

                    client.initializeBackup(passphrase: passphrase)
                    backupService.passphrase = nil
                    updateFactsOnBackup()
                } else {
                    backupService.passphrase = nil
                    client.stopListeningBackup()
                }
            }
            .store(in: &cancellables)

        networkMonitor.statusPublisher
            .sink { print($0) }
            .store(in: &cancellables)

        client.messages
            .sink { [unowned self] in
                if var contact = try? dbManager.fetchContacts(.init(id: [$0.senderId])).first {
                    contact.isRecent = false
                    _ = try? dbManager.saveContact(contact)
                }

                _ = try? dbManager.saveMessage($0)
            }.store(in: &cancellables)

        client.network
            .sink { [unowned self] in networkMonitor.update($0) }
            .store(in: &cancellables)

        client.groupRequests
            .sink { [unowned self] request in
                if let _ = try? dbManager.fetchGroups(.init(id: [request.0.id])).first {
                    return
                }

                DispatchQueue.global().async { [weak self] in
                    self?.processGroupCreation(request.0, memberIds: request.1, welcome: request.2)
                }
            }.store(in: &cancellables)

        client.confirmations
            .sink { [unowned self] in
                if var contact = try? dbManager.fetchContacts(.init(id: [$0.id])).first {
                    contact.authStatus = .friend
                    contact.isRecent = true
                    contact.createdAt = Date()
                    _ = try? dbManager.saveContact(contact)

                    toastController.enqueueToast(model: .init(
                        title: contact.nickname ?? contact.username!,
                        subtitle: Localized.Requests.Confirmations.toaster,
                        leftImage: Asset.sharedSuccess.image
                    ))
                }
            }.store(in: &cancellables)
    }
}
