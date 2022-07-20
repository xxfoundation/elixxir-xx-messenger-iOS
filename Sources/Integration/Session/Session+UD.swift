import Models
import XXModels
import Foundation
import Combine

extension Session {
    public func search(fact: String) -> AnyPublisher<Contact, Error> {
        Deferred {
            Future { promise in
                guard let ud = self.client.userDiscovery else {
                    let error = NSError(domain: "", code: 0)
                    promise(.failure(error))
                    return
                }

                do {
                    try self.client.bindings.nodeRegistrationStatus()
                    try ud.search(fact: fact) {
                        switch $0 {
                        case .success(let contact):
                            promise(.success(contact))
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func search(fact: String, _ completion: @escaping (Result<Contact, Error>) -> Void) throws {
        guard let ud = client.userDiscovery else { return }
        try client.bindings.nodeRegistrationStatus()
        try ud.search(fact: fact, completion)
    }

    public func extract(fact: FactType, from marshalled: Data) throws -> String? {
        guard let ud = client.userDiscovery else { return nil }
        return try ud.retrieve(from: marshalled, fact: fact)
    }

    public func unregister(fact: FactType) throws {
        guard let ud = client.userDiscovery else { return }

        switch fact {
        case .phone:
            try ud.remove("P" + phone!)
            isSharingPhone = false
            phone = nil
        case .email:
            try ud.remove("E" + email!)
            isSharingEmail = false
            email = nil
        default:
            break
        }
    }

    public func register(_ fact: FactType, value: String, _ completion: @escaping (Result<String?, Error>) -> Void) {
        guard let ud = client.userDiscovery else { return }

        switch fact {
        case .username:
            ud.register(.username, value: value) { [weak self] in
                guard let self = self else { return }

                switch $0 {
                case .success(_):
                    self.username = value

                    if var me = try? self.myContact() {
                        me.username = value
                        _ = try? self.dbManager.saveContact(me)
                    }

                    completion(.success(nil))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        default:
            ud.register(fact, value: value, completion)
        }
    }

    public func confirm(code: String, confirmation: AttributeConfirmation) throws {
        guard let ud = client.userDiscovery else { return }

        try ud.confirm(code: code, id: confirmation.confirmationId!)

        if confirmation.isEmail {
            email = confirmation.content
        } else {
            phone = confirmation.content
        }

        if let _ = client.backupManager {
            updateFactsOnBackup()
        }
    }
}
