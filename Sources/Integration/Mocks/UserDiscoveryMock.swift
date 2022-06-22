import Models
import XXModels
import Foundation

final class UserDiscoveryMock: UserDiscoveryInterface {

    func remove(_ fact: String) throws {}

    func deleteMyself(_ username: String) throws {}

    func confirm(code: String, id: String) throws {}

    func lookup(idList: [Data], _: @escaping (Result<[Contact], Error>) -> Void) {}

    func retrieve(from: Data, fact: FactType) throws -> String? { fact.description }

    func search(fact: String, _ completion: @escaping (Result<Contact, Error>) -> Void) throws {
        completion(.success(.georgeDiscovered))
    }

    func register(_: FactType, value: String, _ completion: @escaping (Result<String?, Error>) -> Void) {
        completion(.success("#CONFIRMATION_CODE_FOR \(value)"))
    }

    func lookup(
        forUserId: Data,
        _ completion: @escaping (Result<Contact, Error>) -> Void
    ) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion(.success(
                .init(
                    id: "mock_username".data(using: .utf8)!,
                    marshaled: "mock_username".data(using: .utf8)!,
                    username: "mock_username",
                    email: nil,
                    phone: nil,
                    nickname: "mock_nickname",
                    photo: nil,
                    authStatus: .stranger,
                    isRecent: false,
                    createdAt: Date()
            )))
        }
    }
}
