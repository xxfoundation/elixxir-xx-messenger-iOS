import Models
import Combine
import XXModels
import Foundation

public final class BindingsMock: BindingsInterface {
    private var cancellables = Set<AnyCancellable>()
    private let requestsSubject = PassthroughSubject<Contact, Never>()
    private let groupRequestsSubject = PassthroughSubject<Group, Never>()
    private let confirmationsSubject = PassthroughSubject<Contact, Never>()

    public var hasRunningTasks: Bool {
        false
    }

    public func replayRequests() {}

    public var myId: Data {
        "MOCK_USER".data(using: .utf8)!
    }

    public var receptionId: Data {
        "RECEPTION_ID".data(using: .utf8)!
    }

    public var meMarshalled: Data {
        "MOCK_USER_MARSHALLED".data(using: .utf8)!
    }

    public static var secret: (Int) -> Data? = {
        "\($0)".data(using: .utf8)!
    }

    public func verify(marshaled: Data, verifiedMarshaled: Data) throws -> Bool {
        true
    }

    public static let version: String = "MOCK"

    public static var new: ClientNew = { _,_,_,_,_ in true }

    public static var fromBackup: ClientFromBackup = { _,_,_,_,_,_ in Data() }

    public static var login: (String?, Data?, String?, NSErrorPointer) -> BindingsInterface? = { _,_,_,_ in BindingsMock() }

    public func meMarshalled(_: String, email: String?, phone: String?) -> Data {
        meMarshalled
    }

    public func startNetwork() {}

    public func stopNetwork() {}

    public static func listenLogs() {}

    public static func updateErrors() {}

    public func listenPreImageUpdates() {}

    public func getPreImages() -> String { "" }

    public func nodeRegistrationStatus() throws {}

    public func getId(from: Data) -> Data? { from }

    public func unregisterNotifications() throws {}

    public func registerNotifications(_: Data) throws {}

    public func compress(image: Data, _: @escaping(Result<Data, Error>) -> Void) {}

    public func generateUD() throws -> UserDiscoveryInterface { UserDiscoveryMock() }

    public func generateUDFromBackup(
        email: String?,
        phone: String?
    ) throws -> UserDiscoveryInterface { UserDiscoveryMock() }

    public func generateTransferManager(
        _: @escaping (Data, String?, String?, Data?) -> Void
    ) throws -> TransferManagerInterface {
        TransferManagerMock()
    }

    public func listenEvents(_: @escaping (BackendEvent) -> Void) {}

    public func listenMessages(_: @escaping (Message) -> Void) throws {}


    public func initializeBackup(
        passphrase: String,
        callback: @escaping (Data) -> Void
    ) -> BackupInterface { BindingsBackupMock() }

    public func resumeBackup(
        callback: @escaping (Data) -> Void
    ) -> BackupInterface { BindingsBackupMock() }

    public func listenBackups(_: @escaping (Data) -> Void) -> BackupInterface { fatalError() }

    public func listenNetworkUpdates(_: @escaping (Bool) -> Void) {}

    public func confirm(_: Data, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            completion(.success(true))
        }
    }
    
    public func listenRound(id: Int, _: @escaping (Result<Bool, Error>) -> Void) {}

    public func add(_ contact: Data, from: Data, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
            if contact == Contact.georgeDiscovered.marshaled {
                completion(.success(true))
            } else {
                completion(.success(false))
                return
            }

            self?.requestsSubject.send(.carlRequested)
            self?.requestsSubject.send(.angelinaRequested)
            self?.requestsSubject.send(.elonRequested)

            DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.confirmationsSubject.send(.georgeDiscovered)
            }
        }
    }

    public func send(
        _ payload: Data,
        to recipient: Data
    ) -> Result<E2ESendReportType, Error> {
        .success(MockE2ESendReport())
    }

    public func listen(
        report: Data,
        _ completion: @escaping (Result<MessageDeliveryStatus, Error>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(.success(.sent))
        }
    }

    public func generateDummyTraficManager() throws -> DummyTrafficManaging {
        MockDummyManager()
    }

    public func removeContact(_ data: Data) throws {}

    public func resetSessionWith(_: Data) {}

    public func listenRequests(
        _ requests: @escaping (Contact) -> Void,
        _ confirmations: @escaping (Contact) -> Void,
        _ resets: @escaping (Contact) -> Void
    ) {
        requestsSubject.sink(receiveValue: requests).store(in: &cancellables)
        confirmationsSubject.sink(receiveValue: confirmations).store(in: &cancellables)
    }

    public func listenGroupRequests(
        _ groupRequests: @escaping (Group, [Data], String?) -> Void,
        groupMessages: @escaping (Message) -> Void
    ) throws -> GroupManagerInterface? {
        groupRequestsSubject
            .sink { groupRequests($0, [], nil) }
            .store(in: &cancellables)

        return GroupManagerMock()
    }

    public func restore(
        ids: Data,
        using ud: UserDiscoveryInterface,
        lookupCallback: @escaping (Result<Contact, Error>) -> Void,
        restoreCallback: @escaping (Int, Int, Int, String?) -> Void
    ) -> RestoreReportType {
        fatalError()
    }

    public static func updateNDF(for: NetworkEnvironment, _ completion: @escaping (Result<Data?, Error>) -> Void) {
        completion(.success(Data()))
    }
}

extension Group {
    static let mockGroup = Group(
        id: "mockGroup".data(using: .utf8)!,
        name: "Bruno's birthday 6/1",
        leaderId: "mockGroupLeader".data(using: .utf8)!,
        createdAt: Date.distantPast,
        authStatus: .pending,
        serialized: "mockGroup".data(using: .utf8)!
    )
}

extension Contact {
    static func mock(_ count: Int = 1) -> [Contact] {
        var mocks = [Contact]()

        for n in 0..<count {
            mocks.append(
                .init(
                    id: "brad\(n)".data(using: .utf8)!,
                    marshaled: "brad\(n)".data(using: .utf8)!,
                    username: "brad\(n)",
                    email: "brad\(n)@xx.io",
                    phone: "819820212\(n)5BR",
                    nickname: nil,
                    photo: nil,
                    authStatus: .verified,
                    isRecent: false,
                    createdAt: Date()
            ))
        }

        return mocks
    }

    static let angelinaRequested = Contact(
        id: "angelinajolie".data(using: .utf8)!,
        marshaled: "angelinajolie".data(using: .utf8)!,
        username: "angelinajolie",
        email: nil,
        phone: nil,
        nickname: "Angelica Jolie",
        photo: nil,
        authStatus: .verificationInProgress,
        isRecent: false,
        createdAt: Date()
    )

    static let carlRequested = Contact(
        id: "carlsagan".data(using: .utf8)!,
        marshaled: "carlsagan".data(using: .utf8)!,
        username: "carlsagan",
        email: "carl@jpl.nasa",
        phone: "81982022244BR",
        nickname: "Carl Sagan",
        photo: nil,
        authStatus: .verified,
        isRecent: false,
        createdAt: Date.distantPast
    )

    static let elonRequested = Contact(
        id: "elonmusk".data(using: .utf8)!,
        marshaled: "elonmusk".data(using: .utf8)!,
        username: "elonmusk",
        email: "elon@tesla.com",
        phone: nil,
        nickname: "Elon Musk",
        photo: nil,
        authStatus: .verified,
        isRecent: false,
        createdAt: Date.distantPast
    )

    static let georgeDiscovered = Contact(
        id: "georgebenson74".data(using: .utf8)!,
        marshaled: "georgebenson74".data(using: .utf8)!,
        username: "bruno_muniz74",
        email: "george@xx.io",
        phone: "81987022255BR",
        nickname: "Bruno Muniz",
        photo: nil,
        authStatus: .stranger,
        isRecent: false,
        createdAt: Date()
    )
}

public struct MockE2ESendReport: E2ESendReportType {
    public var timestamp: Int64 { 1 }
    public var marshalled: Data { Data() }
    public var uniqueId: Data? { Data() }
    public var roundURL: String { "https://www.google.com.br" }
}

public struct MockDummyManager: DummyTrafficManaging {
    public var status: Bool { true }

    public func setStatus(status: Bool) {
        print("Dummy manager status set to \(status)")
    }
}

public struct BindingsBackupMock: BackupInterface {
    public func stop() throws {
        // TODO
    }

    public func addJson(_: String?) {
        // TODO
    }

    public func isBackupRunning() -> Bool {
        return true
    }
}
