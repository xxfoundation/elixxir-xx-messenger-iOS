import HUD
import Combine
import Models
import Integration
import DependencyInjection
import Defaults
import UIKit

final class CreateGroupViewModel {
    @KeyObject(.username, defaultValue: "") var username: String

    // MARK: Injected

    @Dependency private var session: SessionType

    // MARK: Properties

    var selected: AnyPublisher<[Contact], Never> {
        selectedContactsRelay.eraseToAnyPublisher()
    }

    var contacts: AnyPublisher<[Contact], Never> {
        contactsRelay.eraseToAnyPublisher()
    }

    var hud: AnyPublisher<HUDStatus, Never> {
        hudRelay.eraseToAnyPublisher()
    }

    var info: AnyPublisher<GroupChatInfo, Never> {
        infoRelay.eraseToAnyPublisher()
    }

    private var allContacts = [Contact]()
    private var cancellables = Set<AnyCancellable>()
    private let infoRelay = PassthroughSubject<GroupChatInfo, Never>()
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)
    private let contactsRelay = CurrentValueSubject<[Contact], Never>([])
    private let selectedContactsRelay = CurrentValueSubject<[Contact], Never>([])

    // MARK: Lifecycle

    init() {
        session.contacts(.friends)
            .map { $0.sorted(by: { $0.username < $1.username })}
            .sink { [unowned self] in
                allContacts = $0
                contactsRelay.send($0)
            }.store(in: &cancellables)
    }

    // MARK: Public

    func didSelect(contact: Contact) {
        if selectedContactsRelay.value.contains(contact) {
            selectedContactsRelay.value.removeAll { $0.username == contact.username }
        } else {
            selectedContactsRelay.value.append(contact)
        }
    }

    func filter(_ text: String) {
        guard text.isEmpty == false else {
            contactsRelay.send(allContacts)
            return
        }

        contactsRelay.send(allContacts.filter { $0.username.contains(text.lowercased()) })
    }

    func create(name: String, welcome: String?, members: [Contact]) {
        hudRelay.send(.on)

        session.createGroup(name: name, welcome: welcome, members: members) { [weak self] in
            guard let self = self else { return }

            self.hudRelay.send(.none)

            switch $0 {
            case .success((let group, let members)):
                self.infoRelay.send(.init(group: group, members: members))
            case .failure(let error):
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }
}
