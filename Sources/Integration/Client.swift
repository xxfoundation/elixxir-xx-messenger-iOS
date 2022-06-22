import Retry
import Models
import Combine
import Defaults
import Bindings
import XXModels
import Foundation

public class Client {
    @KeyObject(.inappnotifications, defaultValue: true) var inappnotifications: Bool

    let bindings: BindingsInterface
    var backupManager: BackupInterface?
    var dummyManager: DummyTrafficManaging?
    var groupManager: GroupManagerInterface?
    var userDiscovery: UserDiscoveryInterface?
    var transferManager: TransferManagerInterface?

    var backup: AnyPublisher<Data, Never> { backupSubject.eraseToAnyPublisher() }
    var network: AnyPublisher<Bool, Never> { networkSubject.eraseToAnyPublisher() }
    var resets: AnyPublisher<Contact, Never> { resetsSubject.eraseToAnyPublisher() }
    var messages: AnyPublisher<Message, Never> { messagesSubject.eraseToAnyPublisher() }
    var requests: AnyPublisher<Contact, Never> { requestsSubject.eraseToAnyPublisher() }
    var events: AnyPublisher<BackendEvent, Never> { eventsSubject.eraseToAnyPublisher() }
    var requestsSent: AnyPublisher<Contact, Never> { requestsSentSubject.eraseToAnyPublisher() }
    var confirmations: AnyPublisher<Contact, Never> { confirmationsSubject.eraseToAnyPublisher() }
    var groupRequests: AnyPublisher<(Group, [Data], String?), Never> { groupRequestsSubject.eraseToAnyPublisher() }

    private let backupSubject = PassthroughSubject<Data, Never>()
    private let networkSubject = PassthroughSubject<Bool, Never>()
    private let resetsSubject = PassthroughSubject<Contact, Never>()
    private let requestsSubject = PassthroughSubject<Contact, Never>()
    private let messagesSubject = PassthroughSubject<Message, Never>()
    private let eventsSubject = PassthroughSubject<BackendEvent, Never>()
    private let requestsSentSubject = PassthroughSubject<Contact, Never>()
    private let confirmationsSubject = PassthroughSubject<Contact, Never>()
    private let groupRequestsSubject = PassthroughSubject<(Group, [Data], String?), Never>()

    private var isBackupInitialization = false
    private var isBackupInitializationCompleted = false

    // MARK: Lifecycle

    init(
        _ bindings: BindingsInterface,
        fromBackup: Bool,
        email: String?,
        phone: String?
    ) {
        self.bindings = bindings
        self.isBackupInitialization = fromBackup

        do {
            try registerListenersAndStart()

            if fromBackup {
                try instantiateUserDiscoveryFromBackup(email: email, phone: phone)
            } else {
                try instantiateUserDiscovery()
            }

            try instantiateTransferManager()
            try instantiateDummyTrafficManager()
            updatePreImage()
        } catch {
            log(string: error.localizedDescription, type: .error)
        }
    }

    public func initializeBackup(passphrase: String) {
        backupManager = nil
        backupManager = bindings.initializeBackup(passphrase: passphrase) { [weak backupSubject] in
            backupSubject?.send($0)
        }
    }

    public func resumeBackup() {
        backupManager = nil
        backupManager = bindings.resumeBackup { [weak backupSubject] in
            backupSubject?.send($0)
        }
    }

    //    public func isBackupRunning() -> Bool {
    //        guard let backupManager = backupManager else { return false }
    //        return backupManager.isBackupRunning()
    //    }

    public func addJson(_ string: String) {
        guard let backupManager = backupManager else { return }
        backupManager.addJson(string)
    }

    public func stopListeningBackup() {
        guard let backupManager = backupManager else { return }
        try? backupManager.stop()
        self.backupManager = nil
    }

    public func restoreContacts(fromBackup backup: Data) {
        var totalPendingRestoration: Int = 0

        let report = bindings.restore(
            ids: backup,
            using: userDiscovery!) { [weak self] in
                guard let self = self else { return }

                switch $0 {
                case .success(var contact):
                    contact.authStatus = .requested
                    self.requestsSentSubject.send(contact)
                    print(">>> Restored \(contact.username). Setting status as requested")
                case .failure(let error):
                    print(">>> \(error.localizedDescription)")
                }
            } restoreCallback: { numFound, numRestored, total, errorString in
                totalPendingRestoration = total
                let results =
            """
            >>> Results from within closure of RestoreContacts:
            - numFound: \(numFound)
            - numRestored: \(numRestored)
            - total: \(total)
            - errorString: \(errorString)
            """
                print(results)
            }

        guard totalPendingRestoration > 0 else { fatalError("Total is zero, why called restore contacts?") }

        guard report.lenRestored() == totalPendingRestoration else {
            print(">>> numRestored \(report.lenRestored()) is != than the total (\(totalPendingRestoration)). Going on recursion...\nnumFailed: \(report.lenFailed())\n\(report.getRestoreContactsError())")
            restoreContacts(fromBackup: backup)
            return
        }

        isBackupInitializationCompleted = true
    }

    private func registerListenersAndStart() throws {
        bindings.listenNetworkUpdates { [weak networkSubject] in networkSubject?.send($0) }

        bindings.listenRequests { [weak self] in
            guard let self = self else { return }

            if self.isBackupInitialization {
                if self.isBackupInitializationCompleted {
                    self.requestsSubject.send($0)
                }
            } else {
                self.requestsSubject.send($0)
            }
        } _: { [weak confirmationsSubject] in
            confirmationsSubject?.send($0)
        } _: { [weak resetsSubject] in
            resetsSubject?.send($0)
        }

        bindings.listenEvents { [weak eventsSubject] in
            eventsSubject?.send($0)
        }

        groupManager = try bindings.listenGroupRequests { [weak groupRequestsSubject] request, members, welcome in
            groupRequestsSubject?.send((request, members, welcome))
        } groupMessages: { [weak messagesSubject] in
            messagesSubject?.send($0)
        }

        bindings.listenPreImageUpdates()

        try bindings.listenMessages { [weak messagesSubject] in
            messagesSubject?.send($0)
        }

        bindings.startNetwork()
    }

    private func instantiateTransferManager() throws {
//        transferManager = try bindings.generateTransferManager { [weak transfersSubject] tid, name, type, sender in
//
//            /// Someone transfered something to me
//            /// but I haven't received yet. I'll store an
//            /// IncomingTransfer object so later on I can
//            /// pull up whatever this contact has sent me.
//            ///
//            guard let name = name,
//                  let type = type,
//                  let contact = sender,
//                  let _extension = Attachment.Extension.from(type) else {
//                      log(string: "Transfer of \(name ?? "nil").\(type ?? "nil") is being dismissed", type: .error)
//                      return
//                  }
//
//            transfersSubject?.send(
//                FileTransfer(
//                    tid: tid,
//                    contact: contact,
//                    fileName: name,
//                    fileType: _extension.written,
//                    isIncoming: true
//                )
//            )
//        }
    }

    private func instantiateUserDiscovery() throws {
        retry(max: 4, retryStrategy: .delay(seconds: 1)) { [weak self] in
            guard let self = self else { return }
            self.userDiscovery = try self.bindings.generateUD()
        }
    }

    private func instantiateUserDiscoveryFromBackup(email: String?, phone: String?) throws {
        retry(max: 4, retryStrategy: .delay(seconds: 1)) { [weak self] in
            guard let self = self else { return }
            self.userDiscovery = try self.bindings.generateUDFromBackup(email: email, phone: phone)
        }
    }

    private func instantiateDummyTrafficManager() throws {
        dummyManager = try bindings.generateDummyTraficManager()
    }

    private func updatePreImage() {
        if let defaults = UserDefaults(suiteName: "group.elixxir.messenger") {
            defaults.set(bindings.getPreImages(), forKey: "preImage")
        }
    }
}
