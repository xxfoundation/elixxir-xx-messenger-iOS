import Retry
import Models
import Combine
import Defaults
import Foundation

public class Client {
    @KeyObject(.inappnotifications, defaultValue: true) var inappnotifications: Bool

    let bindings: BindingsInterface
    var dummyManager: DummyTrafficManaging?
    var groupManager: GroupManagerInterface?
    var userDiscovery: UserDiscoveryInterface?
    var transferManager: TransferManagerInterface?

    var network: AnyPublisher<Bool, Never> { networkSubject.eraseToAnyPublisher() }
    var messages: AnyPublisher<Message, Never> { messagesSubject.eraseToAnyPublisher() }
    var requests: AnyPublisher<Contact, Never> { requestsSubject.eraseToAnyPublisher() }
    var events: AnyPublisher<BackendEvent, Never> { eventsSubject.eraseToAnyPublisher() }
    var confirmations: AnyPublisher<Contact, Never> { confirmationsSubject.eraseToAnyPublisher() }
    var groupMessages: AnyPublisher<GroupMessage, Never> { groupMessagesSubject.eraseToAnyPublisher() }
    var incomingTransfers: AnyPublisher<FileTransfer, Never> { transfersSubject.eraseToAnyPublisher() }
    var groupRequests: AnyPublisher<(Group, [Data], String?), Never> { groupRequestsSubject.eraseToAnyPublisher() }

    private let networkSubject = PassthroughSubject<Bool, Never>()
    private let requestsSubject = PassthroughSubject<Contact, Never>()
    private let messagesSubject = PassthroughSubject<Message, Never>()
    private let eventsSubject = PassthroughSubject<BackendEvent, Never>()
    private let confirmationsSubject = PassthroughSubject<Contact, Never>()
    private let transfersSubject = PassthroughSubject<FileTransfer, Never>()
    private let groupMessagesSubject = PassthroughSubject<GroupMessage, Never>()
    private let groupRequestsSubject = PassthroughSubject<(Group, [Data], String?), Never>()

    // MARK: Lifecycle

    init(_ bindings: BindingsInterface) {
        self.bindings = bindings

        do {
            try registerListenersAndStart()
            try instantiateUserDiscovery()
            try instantiateTransferManager()
            try instantiateDummyTrafficManager()
            updatePreImage()
        } catch {
            log(string: error.localizedDescription, type: .error)
        }
    }

    // MARK: Public

    private func registerListenersAndStart() throws {
        bindings.listenNetworkUpdates { [weak networkSubject] in
            networkSubject?.send($0)
        }

        bindings.listenRequests { [weak self] in
            guard let self = self else { return }
            self.requestsSubject.send($0)
        } confirmations: { [weak confirmationsSubject] in
            confirmationsSubject?.send($0)
        }

        bindings.listenEvents { [weak eventsSubject] in
            eventsSubject?.send($0)
        }

        groupManager = try bindings.listenGroupRequests { [weak groupRequestsSubject] request, members, welcome in
            groupRequestsSubject?.send((request, members, welcome))
        } groupMessages: { [weak groupMessagesSubject] in
            groupMessagesSubject?.send($0)
        }

        bindings.listenPreImageUpdates()

        try bindings.listenMessages { [weak messagesSubject] in
            messagesSubject?.send($0)
        }

        bindings.startNetwork()
    }

    private func instantiateTransferManager() throws {
        transferManager = try bindings.generateTransferManager { [weak transfersSubject] tid, name, type, sender in

            /// Someone transfered something to me
            /// but I haven't received yet. I'll store an
            /// IncomingTransfer object so later on I can
            /// pull up whatever this contact has sent me.
            ///
            guard let name = name,
                  let type = type,
                  let contact = sender,
                  let _extension = Attachment.Extension.from(type) else {
                      log(string: "Transfer of \(name ?? "nil").\(type ?? "nil") is being dismissed", type: .error)
                      return
                  }

            transfersSubject?.send(
                FileTransfer(
                    tid: tid,
                    contact: contact,
                    fileName: name,
                    fileType: _extension.written,
                    isIncoming: true
                )
            )
        }
    }

    private func instantiateUserDiscovery() throws {
        retry(max: 4, retryStrategy: .delay(seconds: 1)) { [weak self] in
            guard let self = self else { return }
            self.userDiscovery = try self.bindings.generateUD()
        }
    }

    private func instantiateDummyTrafficManager() throws {
        dummyManager = try bindings.generateDummyTraficManager()
    }

    private func updatePreImage() {
        if let defaults = UserDefaults(suiteName: "group.io.xxlabs.notification") {
            defaults.set(bindings.getPreImages(), forKey: "preImage")
        }
    }
}
