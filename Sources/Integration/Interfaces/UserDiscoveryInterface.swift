import Models
import XXModels
import Foundation

public struct LookupResult {
    public let id: Data
    public let username: String
}

public protocol UserDiscoveryInterface {

    func remove(_: String) throws

    func deleteMyself(_: String) throws

    func confirm(code: String, id: String) throws

    func retrieve(from: Data, fact: FactType) throws -> String?

    func lookup(forUserId: Data, _: @escaping (Result<Contact, Error>) -> Void)

    func search(fact: String, _: @escaping (Result<Contact, Error>) -> Void) throws

    func lookup(idList: [Data], _: @escaping (Result<[Contact], Error>) -> Void)

    func register(_: FactType, value: String, _: @escaping (Result<String?, Error>) -> Void)
}
