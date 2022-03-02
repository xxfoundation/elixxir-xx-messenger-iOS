import Models
import Foundation

public enum MessageDeliveryStatus {
    case sent
    case failed
    case timedout
}

public typealias BackendEvent = (Int, String?, String?, String?)

public typealias DeliveryResult = (Data?, Bool, Bool, Data?)

public typealias NotificationEvaluation = (String?, String?, NSErrorPointer) -> NotificationManyReportProtocol?

public protocol E2ESendReportType {
    var timestamp: Int64 { get }
    var uniqueId: Data? { get }
    var marshalled: Data { get }
    var roundURL: String { get }
}

public protocol BindingsInterface {

    // MARK: Properties

    var myId: Data { get }

    var hasRunningTasks: Bool { get }

    var receptionId: Data { get }

    var meMarshalled: Data { get }

    func meMarshalled(_: String, email: String?, phone: String?) -> Data

    func verify(marshaled: Data, verifiedMarshaled: Data) throws -> Bool

    func nodeRegistrationStatus() throws

    // MARK: Static

    static func updateErrors()

    static var version: String { get }

    static var secret: (Int) -> Data? { get }

    static var login: (String?, Data?, String?, NSErrorPointer) -> BindingsInterface? { get }

    static var newClient: (String?, String?, Data?, String?, NSErrorPointer) -> Bool { get }

    static func updateNDF(for: NetworkEnvironment, _: @escaping (Result<Data?, Error>) -> Void)

    // MARK: Network

    func startNetwork()
    
    func stopNetwork()

    func replayRequests()

    // MARK: Contacts
    
    func getId(from: Data) -> Data?

    func confirm(_: Data, _: @escaping (Result<Bool, Error>) -> Void)

    func add(_: Data, from: Data, _: @escaping (Result<Bool, Error>) -> Void)

    // MARK: Messages

    func send(_ payload: Data, to recipient: Data) -> Result<E2ESendReportType, Error>

    func compress(image: Data, _: @escaping(Result<Data, Error>) -> Void)

    func listen(
        report: Data,
        _: @escaping (Result<MessageDeliveryStatus, Error>) -> Void
    )
    
    func listenRound(
        id: Int,
        _: @escaping (Result<Bool, Error>) -> Void
    )

    // MARK: Notifications

    func getPreImages() -> String

    func registerNotifications(_: String) throws

    func unregisterNotifications() throws

    func generateDummyTraficManager() throws -> DummyTrafficManaging

    // MARK: UD
    
    func generateUD() throws -> UserDiscoveryInterface

    // MARK: FileTransfer

    func generateTransferManager(
        _: @escaping (Data, String?, String?, Data?) -> Void
    ) throws -> TransferManagerInterface

    // MARK: Listeners

    static func listenLogs()

    func listenEvents(_: @escaping (BackendEvent) -> Void)

    func listenMessages(_: @escaping (Message) -> Void) throws

    func listenRequests(
        _: @escaping (Contact) -> Void,
        confirmations: @escaping (Contact) -> Void
    )

    func listenPreImageUpdates()

    func listenGroupRequests(
        _: @escaping (Group, [Data], String?) -> Void,
        groupMessages: @escaping (GroupMessage) -> Void
    ) throws -> GroupManagerInterface?

    func listenNetworkUpdates(_: @escaping (Bool) -> Void)

    func removeContact(_ data: Data) throws
}
