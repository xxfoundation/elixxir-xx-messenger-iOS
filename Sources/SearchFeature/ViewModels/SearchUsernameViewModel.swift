import HUD
import UIKit
import Combine
import XXModels
import Integration
import DependencyInjection

typealias SearchSnapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>

struct SearchUsernameViewState {
    var input = ""
    var snapshot: SearchSnapshot?
}

final class SearchUsernameViewModel {
    @Dependency var session: SessionType

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var successPublisher: AnyPublisher<Contact, Never> {
        successSubject.eraseToAnyPublisher()
    }

    var statePublisher: AnyPublisher<SearchUsernameViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    private let successSubject = PassthroughSubject<Contact, Never>()
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)
    private let stateSubject = CurrentValueSubject<SearchUsernameViewState, Never>(.init())

    func didEnterInput(_ string: String) {
        stateSubject.value.input = string
    }

    func didStartSearching() {
        hudSubject.send(.on(nil))

        do {
            try session.search(fact: "U\(stateSubject.value.input)") { [weak self] in
                guard let self = self else { return }

                switch $0 {
                case .success(let contact):
                    self.hudSubject.send(.none)
                    self.appendToLocalSearch(contact)

                case .failure(let error):
                    self.appendToLocalSearch(nil)
                    self.hudSubject.send(.error(.init(with: error)))
                }
            }
        } catch {
            hudSubject.send(.error(.init(with: error)))
        }
    }

    func didTapRequest(contact: Contact) {
        hudSubject.send(.on(nil))
        var contact = contact
        contact.nickname = contact.username

        do {
            try self.session.add(contact)
            hudSubject.send(.none)
            successSubject.send(contact)
        } catch {
            hudSubject.send(.error(.init(with: error)))
        }
    }

    func didSet(nickname: String, for contact: Contact) {
        if var contact = try? session.dbManager.fetchContacts(.init(id: [contact.id])).first {
            contact.nickname = nickname
            _ = try? session.dbManager.saveContact(contact)
        }
    }

    private func appendToLocalSearch(_ contact: Contact?) {
        var snapshot = SearchSnapshot()

        if let contact = contact {
            snapshot.appendSections([.stranger])
            snapshot.appendItems([.stranger(contact)], toSection: .stranger)
        }

        if let locals = try? session.dbManager.fetchContacts(Contact.Query(username: stateSubject.value.input)), locals.count > 0 {
            snapshot.appendSections([.connections])
            snapshot.appendItems(locals.map(SearchItem.connection), toSection: .connections)
        }

        stateSubject.value.snapshot = snapshot
    }
}
