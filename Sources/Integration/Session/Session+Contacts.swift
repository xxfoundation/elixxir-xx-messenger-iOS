import Retry
import Models
import Shared
import XXModels
import Foundation

extension Session {
    public func getId(from data: Data) -> Data? {
        client.bindings.getId(from: data)
    }

    public func verify(contact: Contact) {
        log(string: "Requested verification of \(contact.username)", type: .crumbs)

        var contact = contact
        contact.authStatus = .verificationInProgress

        do {
            contact = try dbManager.saveContact(contact)
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
                guard try! self.client.bindings.verify(marshaled: contact.marshaled!, verifiedMarshaled: mightBe.marshaled!) else {
                    log(string: "\(contact.username) is fake. Deleted!", type: .info)

                    do {
                        try self.dbManager.deleteContact(contact)
                    } catch {
                        log(string: error.localizedDescription, type: .error)
                    }

                    return
                }

                contact.authStatus = .verified
                log(string: "Verified \(contact.username)", type: .info)

                do {
                    try self.dbManager.saveContact(contact)
                } catch {
                    log(string: error.localizedDescription, type: .error)
                }

            case .failure(let error):
                log(string: "Verification of \(contact.username) failed: \(error.localizedDescription)", type: .error)
                contact.authStatus = .verificationFailed

                do {
                    try self.dbManager.saveContact(contact)
                } catch {
                    log(string: error.localizedDescription, type: .error)
                }
            }
        }

        let ud = client.userDiscovery!

        let hasEmail = contact.email != nil
        let hasPhone = contact.phone != nil

        guard hasEmail || hasPhone else {
            ud.lookup(forUserId: contact.id, resultClosure)
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
            contact.authStatus = .verificationFailed

            do {
                try self.dbManager.saveContact(contact)
            } catch {
                log(string: error.localizedDescription, type: .error)
            }
        }
    }

    public func retryRequest(_ contact: Contact) throws {
        log(string: "Retrying to request a contact", type: .info)

        client.bindings.add(contact.marshaled!, from: myQR) { [weak self, contact] in
            var contact = contact
            guard let self = self else { return }

            do {
                switch $0 {
                case .success:
                    log(string: "Retrying to request a contact -- Success", type: .info)
                    contact.authStatus = .requested
                case .failure(let error):
                    log(string: "Retrying to request a contact -- Failed: \(error.localizedDescription)", type: .error)
                    contact.createdAt = Date()
                }

                _ = try self.dbManager.saveContact(contact)
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

        if contact.authStatus == .requestFailed || contact.authStatus == .confirmationFailed {
            contactToOperate = contact
        } else {
            guard (try? dbManager.fetch(.withUsername(contact.username)).first as Contact?) == nil else {
                throw NSError.create("This user has already been requested")
            }

            contactToOperate = try dbManager.saveContact(contact)
        }

        guard contactToOperate.authStatus != .confirmationFailed else {
            contactToOperate.createdAt = Date()
            try confirm(contact)
            return
        }

        contactToOperate.authStatus = .requesting

        let myself = client.bindings.meMarshalled(
            username!,
            email: isSharingEmail ? email : nil,
            phone: isSharingPhone ? phone : nil
        )

        client.bindings.add(contactToOperate.marshaled!, from: myself) { [weak self, contactToOperate] in
            guard let self = self, var contactToOperate = contactToOperate else { return }

            do {
                switch $0 {
                case .success(let success):
                    contactToOperate.authStatus = success ? .requested : .requestFailed
                    contactToOperate = try self.dbManager.saveContact(contactToOperate)

                case .failure(let error):
                    contactToOperate.authStatus = .requestFailed
                    contactToOperate.createdAt = Date()
                    contactToOperate = try self.dbManager.saveContact(contactToOperate)

                    self.toastController.enqueueToast(model: .init(
                        title: Localized.Requests.Failed.toast(contactToOperate.nickname ?? contact.username!),
                        color: Asset.accentDanger.color,
                        leftImage: Asset.requestFailedToaster.image
                    ))
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    public func confirm(_ contact: Contact) throws {
        var contact = contact
        contact.authStatus = .confirming
        contact = try dbManager.saveContact(contact)

        client.bindings.confirm(contact.marshaled!) { [weak self] in
            switch $0 {
            case .success(let confirmed):
                contact.isRecent = true
                contact.createdAt = Date()
                contact.authStatus = confirmed ? .friend : .confirmationFailed

            case .failure:
                contact.authStatus = .confirmationFailed
            }

            _ = try? self?.dbManager.saveContact(contact)
        }
    }

    public func deleteContact(_ contact: Contact) throws {
        if let _: FileTransfer = try? dbManager.fetch(.withContactId(contact.userId)).first {
            throw NSError.create("There is an ongoing file transfer with this contact as you are receiving or sending a file, please try again later once it’s done")
        } else {
            print("No pending transfer with this contact. Free to delete")
        }

        try client.bindings.removeContact(contact.marshaled!)
        try dbManager.deleteContact(contact)
    }
}
