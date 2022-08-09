import HUD
import UIKit
import Models
import Combine
import XXModels
import Defaults
import CombineSchedulers
import DependencyInjection

import XXClient

struct ContactViewState: Equatable {
    var title: String?
    var email: String?
    var phone: String?
    var photo: UIImage?
    var username: String?
    var nickname: String?
}

final class ContactViewModel {
    @Dependency var e2e: E2E
    @Dependency var database: Database
    @Dependency var userDiscovery: UserDiscovery
    @Dependency var getFactsFromContact: GetFactsFromContact

    @KeyObject(.username, defaultValue: nil) var username: String?

    var contact: Contact

    var popToRootPublisher: AnyPublisher<Void, Never> { popToRootRelay.eraseToAnyPublisher() }
    var popPublisher: AnyPublisher<Void, Never> { popRelay.eraseToAnyPublisher() }
    var hudPublisher: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    var successPublisher: AnyPublisher<Void, Never> { successRelay.eraseToAnyPublisher() }
    var statePublisher: AnyPublisher<ContactViewState, Never> { stateRelay.eraseToAnyPublisher() }

    private let popRelay = PassthroughSubject<Void, Never>()
    private let popToRootRelay = PassthroughSubject<Void, Never>()
    private let successRelay = PassthroughSubject<Void, Never>()
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)
    private let stateRelay = CurrentValueSubject<ContactViewState, Never>(.init())

    var myId: Data {
        try! GetIdFromContact.live(userDiscovery.getContact())
    }

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    init(_ contact: Contact) {
        self.contact = contact

        let facts = try? getFactsFromContact(contact: contact.marshaled!)
        let email = facts?.first(where: { $0.type == FactType.email.rawValue })?.fact
        let phone = facts?.first(where: { $0.type == FactType.phone.rawValue })?.fact

        stateRelay.value = .init(
            title: contact.nickname ?? contact.username,
            email: email,
            phone: phone,
            photo: contact.photo != nil ? UIImage(data: contact.photo!) : nil,
            username: contact.username,
            nickname: contact.nickname
        )
    }

    func didChoosePhoto(_ photo: UIImage) {
        stateRelay.value.photo = photo
        contact.photo = photo.jpegData(compressionQuality: 0.0)
        _ = try? database.saveContact(contact)
    }

    func didTapDelete() {
        hudRelay.send(.on)

        do {
            try e2e.deleteRequest.partner(contact.id)
            try database.deleteContact(contact)

            hudRelay.send(.none)
            popToRootRelay.send()
        } catch {
            hudRelay.send(.error(.init(with: error)))
        }
    }

    func didTapReject() {
        // TODO: Reject function on the API?
        _ = try? database.deleteContact(contact)
        popRelay.send()
    }

    func didTapClear() {
        _ = try? database.deleteMessages(.init(chat: .direct(myId, contact.id)))
    }

    func didUpdateNickname(_ string: String) {
        contact.nickname = string.isEmpty ? nil : string
        stateRelay.value.title = string.isEmpty ? contact.username : string
        _ = try? database.saveContact(contact)

        stateRelay.value.nickname = contact.nickname
    }

    func didTapResend() {
        hudRelay.send(.on)
        contact.authStatus = .requesting

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.database.saveContact(self.contact)

                var myFacts = try self.userDiscovery.getFacts()
                myFacts.append(Fact(fact: self.username!, type: FactType.username.rawValue))

                let _ = try self.e2e.requestAuthenticatedChannel(
                    partnerContact: self.contact.id,
                    myFacts: myFacts
                )

                self.contact.authStatus = .requested
                try self.database.saveContact(self.contact)

                self.hudRelay.send(.none)
                self.popRelay.send()
            } catch {
                self.contact.authStatus = .requestFailed
                _ = try? self.database.saveContact(self.contact)
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }

    func didTapRequest(with nickname: String) {
        hudRelay.send(.on)
        contact.nickname = nickname
        contact.authStatus = .requesting

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.database.saveContact(self.contact)

                var myFacts = try self.userDiscovery.getFacts()
                myFacts.append(Fact(fact: self.username!, type: FactType.username.rawValue))

                let _ = try self.e2e.requestAuthenticatedChannel(
                    partnerContact: self.contact.marshaled!,
                    myFacts: myFacts
                )

                self.contact.authStatus = .requested
                try self.database.saveContact(self.contact)

                self.hudRelay.send(.none)
                self.successRelay.send()
            } catch {
                self.contact.authStatus = .requestFailed
                _ = try? self.database.saveContact(self.contact)
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }

    func didTapAccept(_ nickname: String) {
        hudRelay.send(.on)
        contact.nickname = nickname
        contact.authStatus = .confirming

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.database.saveContact(self.contact)

                let _ = try self.e2e.confirmReceivedRequest(partnerContact: self.contact.marshaled!)

                self.contact.authStatus = .friend
                try self.database.saveContact(self.contact)

                self.hudRelay.send(.none)
                self.popRelay.send()
            } catch {
                self.contact.authStatus = .confirmationFailed
                _ = try? self.database.saveContact(self.contact)
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }
}
