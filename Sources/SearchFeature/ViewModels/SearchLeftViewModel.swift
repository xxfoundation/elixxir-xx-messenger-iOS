import HUD
import UIKit
import Shared
import Combine
import XXModels
import Countries
import Integration
import DependencyInjection

typealias SearchSnapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>

struct SearchLeftViewState {
    var input = ""
    var snapshot: SearchSnapshot?
    var country: Country = .fromMyPhone()
    var item: SearchSegmentedControl.Item = .username
}

final class SearchLeftViewModel {
    @Dependency var session: SessionType

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var successPublisher: AnyPublisher<Contact, Never> {
        successSubject.eraseToAnyPublisher()
    }

    var statePublisher: AnyPublisher<SearchLeftViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    private var searchCancellables = Set<AnyCancellable>()
    private let successSubject = PassthroughSubject<Contact, Never>()
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)
    private let stateSubject = CurrentValueSubject<SearchLeftViewState, Never>(.init())

    func didEnterInput(_ string: String) {
        stateSubject.value.input = string
    }

    func didPick(country: Country) {
        stateSubject.value.country = country
    }

    func didSelectItem(_ item: SearchSegmentedControl.Item) {
        stateSubject.value.item = item
    }

    func didTapCancelSearch() {
        searchCancellables.forEach { $0.cancel() }
        searchCancellables.removeAll()
        hudSubject.send(.none)
    }

    func didStartSearching() {
        guard stateSubject.value.input.isEmpty == false else { return }

        hudSubject.send(.onAction(Localized.Ud.Search.cancel))

        var content = stateSubject.value.input
        let prefix = stateSubject.value.item.written.first!.uppercased()

        if stateSubject.value.item == .phone {
            content += stateSubject.value.country.code
        }

        session.search(fact: "\(prefix)\(content)")
            .sink { [unowned self] in
                if case .failure(let error) = $0 {
                    self.appendToLocalSearch(nil)
                    self.hudSubject.send(.error(.init(with: error)))
                }
            } receiveValue: { contact in
                self.hudSubject.send(.none)
                self.appendToLocalSearch(contact)
            }.store(in: &searchCancellables)
    }

    func didTapResend(contact: Contact) {
        hudSubject.send(.on)

        do {
            try self.session.retryRequest(contact)
            hudSubject.send(.none)
        } catch {
            hudSubject.send(.error(.init(with: error)))
        }
    }

    func didTapRequest(contact: Contact) {
        hudSubject.send(.on)
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

    private func appendToLocalSearch(_ user: Contact?) {
        var snapshot = SearchSnapshot()

        if var user = user {
            if let contact = try? session.dbManager.fetchContacts(.init(id: [user.id])).first {
                user.authStatus = contact.authStatus
            }

            if user.authStatus != .friend {
                snapshot.appendSections([.stranger])
                snapshot.appendItems([.stranger(user)], toSection: .stranger)
            }
        }

        let localsQuery = Contact.Query(text: stateSubject.value.input, authStatus: [.friend])

        if let locals = try? session.dbManager.fetchContacts(localsQuery),
           let localsWithoutMe = removeMyself(from: locals),
           localsWithoutMe.isEmpty == false {
            snapshot.appendSections([.connections])
            snapshot.appendItems(
                localsWithoutMe.map(SearchItem.connection),
                toSection: .connections
            )
        }

        stateSubject.value.snapshot = snapshot
    }

    private func removeMyself(from collection: [Contact]) -> [Contact]? {
        collection.filter { $0.id != session.myId }
    }
}
