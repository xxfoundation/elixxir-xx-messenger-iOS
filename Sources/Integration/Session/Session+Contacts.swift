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

        let resultClosure: (Result<Contact, Error>) -> Void = { result in
            switch result {
            case .success(let mightBe):
                guard try! self.client.bindings.verify(marshaled: contact.marshaled!, verifiedMarshaled: mightBe.marshaled!) else {
                    do {
                        try self.dbManager.deleteContact(contact)
                    } catch {
                        log(string: error.localizedDescription, type: .error)
                    }

                    return
                }

                contact.authStatus = .verified

                do {
                    try self.dbManager.saveContact(contact)
                } catch {
                    log(string: error.localizedDescription, type: .error)
                }

            case .failure:
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
        let name = (contact.nickname ?? contact.username) ?? ""

        client.bindings.add(contact.marshaled!, from: myQR) { [weak self, contact] in
            var contact = contact
            guard let self = self else { return }

            do {
                switch $0 {
                case .success:
                    contact.authStatus = .requested

                    self.toastController.enqueueToast(model: .init(
                        title: Localized.Requests.Sent.Toast.resent(name),
                        leftImage: Asset.sharedSuccess.image
                    ))

                case .failure:
                    contact.createdAt = Date()

                    self.toastController.enqueueToast(model: .init(
                        title: Localized.Requests.Sent.Toast.resentFailed(name),
                        color: Asset.accentDanger.color,
                        leftImage: Asset.requestFailedToaster.image
                    ))
                }

                _ = try self.dbManager.saveContact(contact)
            } catch {
                log(string: error.localizedDescription, type: .error)
            }
        }
    }

    public func add(_ contact: Contact) throws {
        /// Make sure we are not adding ourselves
        ///
        guard contact.username != username else {
            throw NSError.create("You can't add yourself")
        }

        var contact = contact

        /// Check if this contact is actually
        /// being requested/confirmed after failing
        ///
        if [.requestFailed, .confirmationFailed].contains(contact.authStatus) {
            /// If it is being re-requested or
            /// re-confirmed, no need to save again
            ///
            contact.createdAt = Date()

            if contact.authStatus == .confirmationFailed {
                try confirm(contact)
                return
            }
        } else {
            /// If its not failed, lets make sure that
            /// this is an actual new contact
            ///
          if let existent = try? dbManager.fetchContacts(.init(id: [contact.id], authStatus: [.requested, .requesting, .requestFailed])).first {
                throw NSError.create("This user has already been requested")
            }

            contact.authStatus = .requesting
        }

        contact = try dbManager.saveContact(contact)

        let myself = client.bindings.meMarshalled(
            username!,
            email: isSharingEmail ? email : nil,
            phone: isSharingPhone ? phone : nil
        )

        client.bindings.add(contact.marshaled!, from: myself) { [weak self, contact] in
            guard let self = self else { return }
            var contact = contact

            do {
                switch $0 {
                case .success(let success):
                    contact.authStatus = success ? .requested : .requestFailed
                    contact = try self.dbManager.saveContact(contact)

                    let name = contact.nickname ?? contact.username

                    self.toastController.enqueueToast(model: .init(
                        title: Localized.Requests.Sent.Toast.sent(name ?? ""),
                        leftImage: Asset.sharedSuccess.image
                    ))

                case .failure:
                    contact.createdAt = Date()
                    contact.authStatus = .requestFailed
                    contact = try self.dbManager.saveContact(contact)

                    self.toastController.enqueueToast(model: .init(
                        title: Localized.Requests.Failed.toast(contact.nickname ?? contact.username!),
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
        if !(try dbManager.fetchFileTransfers(.init(contactId: contact.id))).isEmpty {
            throw NSError.create("There is an ongoing file transfer with this contact as you are receiving or sending a file, please try again later once it’s done")
        }

        try client.bindings.removeContact(contact.marshaled!)

        /// Currently this cascades into deleting
        /// all messages w/ contact.id == senderId
        /// But this shouldn't be the always the case
        /// because if we have a group / this contact
        /// the messages will be gone as well.
        ///
        /// Suggestion: If there's a group where this user belongs to
        /// we will just cleanup the contact model stored on the db
        /// leaving only username and id which are the equivalent to
        /// .stranger contacts.
        ///
        //try dbManager.deleteContact(contact)

        var contact = contact
        contact.email = nil
        contact.phone = nil
        contact.photo = nil
        contact.isRecent = false
        contact.marshaled = nil
        contact.isBlocked = true
        contact.authStatus = .stranger
        contact.nickname = contact.username
        _ = try! dbManager.saveContact(contact)
    }
}
