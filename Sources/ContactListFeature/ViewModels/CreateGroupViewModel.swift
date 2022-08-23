import HUD
import UIKit
import Models
import Combine
import XXModels
import Defaults
import Integration
import DependencyInjection

final class CreateGroupViewModel {
    @KeyObject(.username, defaultValue: "") var username: String
    @KeyObject(.isReportingEnabled, defaultValue: true) var isReportingEnabled: Bool

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

    var info: AnyPublisher<GroupInfo, Never> {
        infoRelay.eraseToAnyPublisher()
    }

    private var allContacts = [Contact]()
    private var cancellables = Set<AnyCancellable>()
    private let infoRelay = PassthroughSubject<GroupInfo, Never>()
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)
    private let contactsRelay = CurrentValueSubject<[Contact], Never>([])
    private let selectedContactsRelay = CurrentValueSubject<[Contact], Never>([])

    // MARK: Lifecycle

    init() {
        let query = Contact.Query(
            authStatus: [.friend],
            isBlocked: isReportingEnabled ? false : nil,
            isBanned: isReportingEnabled ? false : nil
        )

        session.dbManager.fetchContactsPublisher(query)
            .assertNoFailure()
            .map { $0.filter { $0.id != self.session.myId }}
            .map { $0.sorted(by: { $0.username! < $1.username! })}
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

        contactsRelay.send(
            allContacts.filter {
                ($0.username ?? "").contains(text.lowercased())
            }
        )
    }

    func create(name: String, welcome: String?, members: [Contact]) {
        hudRelay.send(.on)

        session.createGroup(name: name, welcome: welcome, members: members) { [weak self] in
            guard let self = self else { return }

            self.hudRelay.send(.none)

            switch $0 {
            case .success(let info):
                self.infoRelay.send(info)
            case .failure(let error):
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }
}
