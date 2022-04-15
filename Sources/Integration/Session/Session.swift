import Retry
import Models
import Shared
import Combine
import Defaults
import Database
import Foundation
import BackupFeature
import NetworkMonitor
import DependencyInjection

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
    @Dependency var networkMonitor: NetworkMonitoring

    public let client: Client
    public let dbManager: DatabaseManager
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

    lazy public var groups: (Group.Request) -> AnyPublisher<[Group], Never> = {
        self.dbManager.publisher(fetch: Group.self, $0).catch { _ in Just([]) }.eraseToAnyPublisher()
    }

    lazy public var contacts: (Contact.Request) -> AnyPublisher<[Contact], Never> = {
        self.dbManager.publisher(fetch: Contact.self, $0).catch { _ in Just([]) }.eraseToAnyPublisher()
    }

    lazy public var singleMessages: (Contact) -> AnyPublisher<[Message], Never> = {
        self.dbManager.publisher(fetch: Message.self, .withContact($0.userId)).catch { _ in Just([]) }.eraseToAnyPublisher()
    }

    lazy public var groupMessages: (Group) -> AnyPublisher<[GroupMessage], Never> = {
        self.dbManager.publisher(fetch: GroupMessage.self, .fromGroup($0.groupId)).catch { _ in Just([]) }.eraseToAnyPublisher()
    }

    lazy public var groupChats: (GroupChatInfo.Request) -> AnyPublisher<[GroupChatInfo], Never> = {
        self.dbManager.publisher(fetch: GroupChatInfo.self, $0).catch { _ in Just([]) }.eraseToAnyPublisher()
    }

    lazy public var singleChats: (SingleChatInfo.Request) -> AnyPublisher<[SingleChatInfo], Never> = { _ in
        self.dbManager.publisher(fetch: Contact.self, .friends)
            .flatMap { [unowned self] contactList -> AnyPublisher<[SingleChatInfo], Error> in
                let contactIds = contactList.map { $0.userId }

                let messagesPublisher: AnyPublisher<[Message], Error> = dbManager
                    .publisher(fetch: .latestOnesFromContactIds(contactIds))
                    .map { $0.sorted(by: { $0.timestamp > $1.timestamp }) }
                    .eraseToAnyPublisher()

                return messagesPublisher.map { messages -> [SingleChatInfo] in
                    contactList.map { contact -> SingleChatInfo in
                        SingleChatInfo(contact: contact, lastMessage: messages.first {
                            $0.sender == contact.userId || $0.receiver == contact.userId
                        })
                    }
                }
                .eraseToAnyPublisher()
            }
            .catch { _ in Just([]) }
            .map { $0.filter { $0.lastMessage != nil }}
            .map { $0.sorted(by: { $0.lastMessage!.timestamp > $1.lastMessage!.timestamp })}
            .eraseToAnyPublisher()
    }

    public init(backupFile: Data, ndf: String) throws {
        let network = try! DependencyInjection.Container.shared.resolve() as XXNetworking
        let (client, backupData) = try network.newClientFromBackup(data: backupFile, ndf: ndf)
        self.client = client
        dbManager = GRDBDatabaseManager()

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
        dbManager = GRDBDatabaseManager()
        try continueInitialization()
    }

    private func continueInitialization() throws {
        try dbManager.setup()

        setupBindings()
        networkMonitor.start()

        networkMonitor.statusPublisher
            .filter { $0 == .available }.first()
            .sink { [unowned self] _ in client.bindings.replayRequests() }
            .store(in: &cancellables)

        registerUnfinishedTransfers()

        if let pendingVerificationUsers: [Contact] = try? dbManager.fetch(.verificationInProgress) {
            pendingVerificationUsers.forEach {
                var contact = $0
                contact.status = .verificationFailed
                _ = try? dbManager.save(contact)
            }
        }
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

        dbManager.drop()
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

    public func forceFailMessages() {
        if let pendingE2E: [Message] = try? dbManager.fetch(.sending) {
            pendingE2E.forEach {
                var message = $0
                message.status = .failedToSend
                _ = try? dbManager.save(message)
            }
        }

        if let pendingGroupMessages: [GroupMessage] = try? dbManager.fetch(.sending) {
            pendingGroupMessages.forEach {
                var message = $0
                message.status = .failed
                _ = try? dbManager.save(message)
            }
        }
    }

    private func registerUnfinishedTransfers() {
        guard let unfinisheds: [Message] = try? dbManager.fetch(.sendingAttachment), !unfinisheds.isEmpty else { return }

        for var message in unfinisheds {
            guard let tid = message.payload.attachment?.transferId else { return }

            do {
                try client.transferManager?.listenUploadFromTransfer(with: tid) { completed, sent, arrived, total, error in
                    if completed {
                        message.status = .sent
                        message.payload.attachment?.progress = 1.0

                        if let transfer: FileTransfer = try? self.dbManager.fetch(.withTID(tid)).first {
                            try? self.dbManager.delete(transfer)
                        }
                    } else {
                        if let error = error {
                            log(string: error.localizedDescription, type: .error)
                            message.status = .failedToSend
                        } else {
                            let progress = Float(arrived)/Float(total)
                            message.payload.attachment?.progress = progress
                            return
                        }
                    }

                    _ = try? self.dbManager.save(message)
                }
            } catch {
                message.status = .sent
                _ = try? self.dbManager.save(message)
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
            .sink { [unowned self] request in
                if let _: Contact = try? dbManager.fetch(.withUserId(request.userId)).first { return }

                if self.inappnotifications {
                    DeviceFeedback.sound(.contactAdded)
                    DeviceFeedback.shake(.notification)
                }

                verify(contact: request)
            }.store(in: &cancellables)

        client.requestsSent
            .sink { [unowned self] in _ = try? dbManager.save($0) }
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
                contact.status = .friend
                _ = try? dbManager.save(contact)
            }.store(in: &cancellables)

        backupService.settingsPublisher
            .map { $0.enabledService != nil }
            .removeDuplicates()
            .sink { [unowned self] in
                if $0 == true {
                    client.listenBackup()
                    updateFactsOnBackup()
                } else {
                    client.stopListeningBackup()
                }
            }
            .store(in: &cancellables)

        networkMonitor.statusPublisher
            .sink { print($0) }
            .store(in: &cancellables)

        client.groupMessages
            .sink { [unowned self] in _ = try? dbManager.save($0) }
            .store(in: &cancellables)

        client.messages
            .sink { [unowned self] in _ = try? dbManager.save($0) }
            .store(in: &cancellables)

        client.network
            .sink { [unowned self] in networkMonitor.update($0) }
            .store(in: &cancellables)

        client.incomingTransfers
            .sink { [unowned self] in handle(incomingTransfer: $0) }
            .store(in: &cancellables)

        client.groupRequests
            .sink { [unowned self] request in
                if let _: Group = try? dbManager.fetch(.withGroupId(request.0.groupId)).first { return }

                DispatchQueue.global().async { [weak self] in
                    self?.processGroupCreation(request.0, memberIds: request.1, welcome: request.2)
                }
            }.store(in: &cancellables)

        client.confirmations
            .sink { [unowned self] in
                if var contact: Contact = try? dbManager.fetch(.withUserId($0.userId)).first {
                    contact.status = .friend
                    _ = try? dbManager.save(contact)
                }
            }.store(in: &cancellables)
    }

    public func getTextFromMessage(messageId: Data) -> String? {
        guard let message: Message = try? dbManager.fetch(.withUniqueId(messageId)).first else { return nil }
        return message.payload.text
    }

    public func getTextFromGroupMessage(messageId: Data) -> String? {
        guard let message: GroupMessage = try? dbManager.fetch(.withUniqueId(messageId)).first else { return nil }
        return message.payload.text
    }
}
