import Retry
import Models
import Database
import Foundation

extension Session {
    public func getId(from data: Data) -> Data? {
        client.bindings.getId(from: data)
    }

    public func verify(contact: Contact) {
        log(string: "Requested verification of \(contact.username)", type: .crumbs)

        var contact = contact
        contact.status = .verificationInProgress

        do {
            contact = try dbManager.save(contact)
        } catch {
            log(string: "Failed to store contact request upon verification. Returning, request will be abandoned to not crash", type: .error)
        }

        retry(max: 4, retryStrategy: .delay(seconds: 1)) { [weak self] in
            if self?.networkMonitor.xxStatus != .available {
                log(string: "Network is not available yet for ownership. Retrying in 1 second...", type: .error)
                throw NSError.create("")
            }
        }.finalCatch { error in
            log(string: "Failed to verify contact cause network wasn't available at all", type: .crumbs)
            return
        }

        log(string: "Network is available. Verifying \(contact.username)", type: .crumbs)

        let resultClosure: (Result<Contact, Error>) -> Void = { result in
            switch result {
            case .success(let mightBe):
                guard try! self.client.bindings.verify(marshaled: contact.marshaled, verifiedMarshaled: mightBe.marshaled) else {
                    log(string: "\(contact.username) is fake. Deleted!", type: .info)

                    do {
                        try self.dbManager.delete(contact)
                    } catch {
                        log(string: error.localizedDescription, type: .error)
                    }

                    return
                }

                contact.status = .verified
                log(string: "Verified \(contact.username)", type: .info)

                do {
                    try self.dbManager.save(contact)
                } catch {
                    log(string: error.localizedDescription, type: .error)
                }

            case .failure(let error):
                log(string: "Verification of \(contact.username) failed: \(error.localizedDescription)", type: .error)
                contact.status = .verificationFailed

                do {
                    try self.dbManager.save(contact)
                } catch {
                    log(string: error.localizedDescription, type: .error)
                }
            }
        }

        let ud = client.userDiscovery!

        let hasEmail = contact.email != nil
        let hasPhone = contact.phone != nil

        guard hasEmail || hasPhone else {
            ud.lookup(forUserId: contact.userId, resultClosure)
            return
        }

        var fact: String

        if hasEmail {
            fact = "\(FactType.email.prefix)\(contact.email!)"
        } else {
            fact = "\(FactType.phone.prefix)\(contact.phone!)"
        }

        do {
            try ud.search(fact: fact, resultClosure)
        } catch {
            log(string: error.localizedDescription, type: .error)
            contact.status = .verificationFailed

            do {
                try self.dbManager.save(contact)
            } catch {
                log(string: error.localizedDescription, type: .error)
            }
        }
    }

    public func retryRequest(_ contact: Contact) throws {
        log(string: "Retrying to request a contact", type: .info)

        client.bindings.add(contact.marshaled, from: myQR) { [weak self, contact] in
            var contact = contact
            guard let self = self else { return }

            do {
                switch $0 {
                case .success:
                    log(string: "Retrying to request a contact -- Success", type: .info)
                    contact.status = .requested
                case .failure(let error):
                    log(string: "Retrying to request a contact -- Failed: \(error.localizedDescription)", type: .error)
                    contact.createdAt = Date()
                }

                _ = try self.dbManager.save(contact)
            } catch {
                log(string: error.localizedDescription, type: .error)
            }
        }
    }

    public func add(_ contact: Contact) throws {
        guard contact.username != username else {
            throw NSError.create("You can't add yourself")
        }

        var contactToOperate: Contact!

        if contact.status == .requestFailed || contact.status == .confirmationFailed {
            contactToOperate = contact
        } else {
            guard (try? dbManager.fetch(.withUsername(contact.username)).first as Contact?) == nil else {
                throw NSError.create("This user has already been requested")
            }

            contactToOperate = try dbManager.save(contact)
        }

        guard contactToOperate.status != .confirmationFailed else {
            contactToOperate.createdAt = Date()
            try confirm(contact)
            return
        }

        contactToOperate.status = .requesting

        let myself = client.bindings.meMarshalled(username!, email: nil, phone: nil)

        client.bindings.add(contactToOperate.marshaled, from: myself) { [weak self, contactToOperate] in
            guard let self = self, var contactToOperate = contactToOperate else { return }
            let safeName = contactToOperate.nickname ?? contactToOperate.username
            let title = "\(safeName.prefix(2))...\(safeName.suffix(3))"

            do {
                switch $0 {
                case .success(let success):
                    contactToOperate.status = success ? .requested : .requestFailed
                    contactToOperate = try self.dbManager.save(contactToOperate)

                    log(string: "Successfully added \(title)", type: .info)
                case .failure(let error):
                    contactToOperate.status = .requestFailed
                    contactToOperate.createdAt = Date()
                    contactToOperate = try self.dbManager.save(contactToOperate)

                    log(string: "Failed when adding \(title):\n\(error.localizedDescription)", type: .error)
                }
            } catch {
                log(string: "Error adding \(title):\n\(error.localizedDescription)", type: .error)
            }
        }
    }

    public func confirm(_ contact: Contact) throws {
        var contact = contact
        contact.status = .confirming
        contact = try dbManager.save(contact)

        client.bindings.confirm(contact.marshaled) { [weak self] in
            let safeName = contact.nickname ?? contact.username
            let title = "\(safeName.prefix(2))...\(safeName.suffix(3))"

            switch $0 {
            case .success(let confirmed):
                contact.status = confirmed ? .friend : .confirmationFailed
                log(string: "Confirming request from \(title) = \(confirmed)", type: confirmed ? .info : .error)
            case .failure(let error):
                contact.status = .confirmationFailed
                log(string: "Error confirming request from \(title):\n\(error.localizedDescription)", type: .error)
            }

            _ = try? self?.dbManager.save(contact)
        }
    }

    public func update(_ contact: Contact) {
        do {
            if var stored = try dbManager.fetch(.withUsername(contact.username)).first as Contact? {
                stored.email = contact.email
                stored.photo = contact.photo
                stored.phone = contact.phone
                stored.nickname = contact.nickname
                try dbManager.save(stored)

                try dbManager.updateAll(
                    GroupMember.self,
                    GroupMember.Request.withUserId(stored.userId),
                    with: [GroupMember.Column.photo.set(to: stored.photo)]
                )
            }
        } catch {
            log(string: "Error updating a contact: \(error.localizedDescription)", type: .error)
        }
    }

    public func delete<T: Persistable>(_ model: T, isRequest: Bool = false) {
        log(string: "Deleting a model...", type: .info)

        do {
            try dbManager.delete(model)
        } catch {
            log(string: "Error deleting a model: \(error.localizedDescription)", type: .error)
        }
    }

    public func find(by username: String) -> Contact? {
        log(string: "Trying to find contact with username: \(username)", type: .info)

        do {
            if let contact: Contact = try dbManager.fetch(.withUsername(username)).first {
                log(string: "Found \(username)!", type: .info)
                return contact
            } else {
                log(string: "No such contact with username: \(username)", type: .info)
                return nil
            }
        } catch {
            log(string: "Error trying to find a contact: \(error.localizedDescription)", type: .error)
        }

        return nil
    }

    public func deleteContact(_ contact: Contact) throws {
        if let _: FileTransfer = try? dbManager.fetch(.withContactId(contact.userId)).first {
            throw NSError.create("There is an ongoing file transfer with this contact as you are receiving or sending a file, please try again later once it’s done")
        } else {
            print("No pending transfer with this contact. Free to delete")
        }

        try client.bindings.removeContact(contact.marshaled)
        try dbManager.delete(contact)
    }
}
