import HUD
import UIKit
import Models
import Combine
import Integration
import CombineSchedulers
import DependencyInjection

struct ContactViewState: Equatable {
    var title: String?
    var email: String?
    var phone: String?
    var photo: UIImage?
    var username: String?
    var nickname: String?
}

final class ContactViewModel {
    @Dependency private var session: SessionType

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

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    init(_ contact: Contact) {
        self.contact = contact

        do {
            let email = try session.extract(fact: .email, from: contact.marshaled)
            let phone = try session.extract(fact: .phone, from: contact.marshaled)

            stateRelay.value = .init(
                title: contact.nickname ?? contact.username,
                email: email,
                phone: phone,
                photo: contact.photo != nil ? UIImage(data: contact.photo!) : nil,
                username: contact.username,
                nickname: contact.nickname
            )
        } catch {
            print(error.localizedDescription)
        }
    }

    func didChoosePhoto(_ photo: UIImage) {
        stateRelay.value.photo = photo
        contact.photo = photo.jpegData(compressionQuality: 0.0)
        session.update(contact)
    }

    func didTapDelete() {
        hudRelay.send(.on(nil))

        do {
            try session.deleteContact(contact)
            hudRelay.send(.none)
            popToRootRelay.send()
        } catch {
            hudRelay.send(.error(.init(with: error)))
        }
    }

    func didTapReject() {
        session.delete(contact, isRequest: true)
        popRelay.send()
    }

    func didTapClear() {
        session.deleteAll(from: contact)
    }

    func didUpdateNickname(_ string: String) {
        contact.nickname = string.isEmpty ? nil : string
        stateRelay.value.title = string.isEmpty ? contact.username : string
        session.update(contact)

        stateRelay.value.nickname = contact.nickname
    }

    func didTapResend() {
        hudRelay.send(.on(nil))

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.session.add(self.contact)
                self.hudRelay.send(.none)
                self.popRelay.send()
            } catch {
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }

    func didTapRequest(with nickname: String) {
        hudRelay.send(.on(nil))
        contact.nickname = nickname

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.session.add(self.contact)
                self.hudRelay.send(.none)
                self.successRelay.send()
            } catch {
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }

    func didTapAccept(_ nickname: String) {
        hudRelay.send(.on(nil))
        contact.nickname = nickname

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.session.confirm(self.contact)
                self.hudRelay.send(.none)
                self.popRelay.send()
            } catch {
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }
}
