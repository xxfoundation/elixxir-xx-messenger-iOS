import Models
import Combine
import XXModels
import Foundation

public protocol SessionType {
    var myId: Data { get }
    var myQR: Data { get }
    var version: String { get }
    var hasRunningTasks: Bool { get }
    var isOnline: AnyPublisher<Bool, Never> { get }

    func deleteMyself() throws
    func getId(from: Data) -> Data?

    func send(imageData: Data, to: Contact, completion: @escaping (Result<Void, Error>) -> Void)

    func verify(contact: Contact)

    func setDummyTraffic(status: Bool)

    // UserDiscovery

    func unregister(fact: FactType) throws
    func extract(fact: FactType, from: Data) throws -> String?
    func confirm(code: String, confirmation: AttributeConfirmation) throws
    func search(fact: String, _: @escaping (Result<Contact, Error>) -> Void) throws
    func register(_: FactType, value: String, _: @escaping (Result<String?, Error>) -> Void)

    // Notifications

    func unregisterNotifications() throws
    func registerNotifications(_ token: Data) throws

    // Network

    func start()
    func stop()

    // Messages

    func retryMessage(_: Int64)
    func retryGroupMessage(_: Int64)
    func send(_: Payload, toContact: Contact)

    // Contacts

    func add(_: Contact) throws
    func confirm(_: Contact) throws
    func deleteContact(_: Contact) throws

    func retryRequest(_: Contact) throws
    func scanStrangers(_: @escaping () -> Void)

    // Groups

    func join(group: Group) throws
    func send(_: Payload, toGroup: Group)
    func leave(group: Group) throws

    func createGroup(
        name: String,
        welcome: String?,
        members: [Contact],
        _ completion: @escaping (Result<(Group, [GroupMember]), Error>) -> Void
    )
}
