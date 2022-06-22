import Retry
import Models
import XXModels
import Bindings
import Foundation

extension BindingsUserDiscovery: UserDiscoveryInterface {
    public func lookup(forUserId: Data, _ completion: @escaping (Result<Contact, Error>) -> Void) {
        let callback = LookupCallback {
            switch $0 {
            case .success(let contact):
                completion(.success(.init(with: contact, status: .stranger)))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        retry(max: 10, retryStrategy: .delay(seconds: 1)) { [weak self] in
            guard let self = self else { return }
            try self.lookup(forUserId, callback: callback, timeoutMS: 20000)
        }.finalCatch { error in
            log(string: "UD.lookup 4E2E failed:\n\(error.localizedDescription)", type: .error)
            completion(.failure(error.friendly()))
        }
    }

    public func lookup(idList: [Data], _ completion: @escaping (Result<[Contact], Error>) -> Void) {
        let list = BindingsIdList()
        idList.forEach { try? list.add($0) }

        let callback = MultiLookupCallback { [weak self] contactList, idList, error in
            guard let self = self else { return }

            if let error = error, error.count > 2 {
                log(string: "UD.lookup group failed: \(error)", type: .error)
                completion(.failure(NSError.create(error).friendly()))
                return
            }

            guard let contacts = contactList else { return }
            let count = contacts.len()
            var results = [Contact]()

            for index in 0..<count {
                guard let contact = try? contacts.get(index),
                      let marshal = try? contact.marshal(),
                      ((try? self.retrieve(from: marshal, fact: .username) != nil) != nil) else {
                    log(string: "Skipping", type: .error); continue
                }

                results.append(Contact(with: contact, status: .stranger))
            }

            completion(.success(results))
        }

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            do {
                try self.multiLookup(list, callback: callback, timeoutMS: 30000)
            } catch {
                log(string: "UD.lookup group failed: \(error.localizedDescription)", type: .error)
                completion(.failure(error.friendly()))
            }
        }
    }

    public func deleteMyself(_ username: String) throws {
        log(type: .crumbs)

        do {
            try removeUser("U\(username)")
        } catch {
            throw error.friendly()
        }
    }

    public func register(_ fact: FactType, value: String, _ completion: @escaping (Result<String?, Error>) -> Void) {
        log(type: .crumbs)

        if fact == .username {
            do {
                try register(value)
                completion(.success(value))
                return
            } catch {
                completion(.failure(error.friendly()))
                return
            }
        }

        var error: NSError?
        let bindingsFact = BindingsNewFact(fact.rawValue, value, &error)

        if let error = error {
            completion(.failure(error.friendly()))
            return
        }

        var otherError: NSError?
        let confirmationId = addFact(bindingsFact?.stringify(), error: &otherError)

        if let otherError = otherError {
            completion(.failure(otherError))
            return
        }

        completion(.success(confirmationId))
    }

    public func confirm(code: String, id: String) throws {
        log(type: .crumbs)

        do {
            try confirmFact(id, code: code)
        } catch {
            throw error.friendly()
        }
    }

    public func retrieve(
        from marshaled: Data,
        fact: FactType
    ) throws -> String? {

        log(type: .crumbs)

        var error: NSError?
        let contact = BindingsUnmarshalContact(marshaled, &error)
        if let err = error {
            throw err.friendly()
        }

        return contact?.retrieve(fact: fact)
    }

    public func remove(_ fact: String) throws {
        log(type: .crumbs)

        do {
            try removeFact(fact)
        } catch {
            throw error.friendly()
        }
    }

    public func search(fact: String, _ completion: @escaping (Result<Contact, Error>) -> Void) throws {
        log(type: .crumbs)

        let callback = SearchCallback {
            switch $0 {
            case .success(let contact):
                completion(.success(Contact(with: contact, status: .stranger)))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        do {
            try searchSingle(fact, callback: callback, timeoutMS: 50000)
        } catch {
            throw error.friendly()
        }
    }
}
