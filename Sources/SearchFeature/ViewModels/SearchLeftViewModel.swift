import HUD
import UIKit
import Shared
import Combine
import XXModels
import XXClient
import Defaults
import Countries
import Models
import Defaults
import CustomDump
import NetworkMonitor
import ReportingFeature
import CombineSchedulers
import DependencyInjection

typealias SearchSnapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>

struct SearchLeftViewState {
    var input = ""
    var snapshot: SearchSnapshot?
    var country: Country = .fromMyPhone()
    var item: SearchSegmentedControl.Item = .username
}

final class SearchLeftViewModel {
    @Dependency var e2e: E2E
    @Dependency var database: Database
    @Dependency var userDiscovery: UserDiscovery
    @Dependency var reportingStatus: ReportingStatus
    @Dependency var networkMonitor: NetworkMonitoring

    @KeyObject(.username, defaultValue: nil) var username: String?

    var myId: Data {
        try! GetIdFromContact.live(userDiscovery.getContact())
    }

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var successPublisher: AnyPublisher<Contact, Never> {
        successSubject.eraseToAnyPublisher()
    }

    var statePublisher: AnyPublisher<SearchLeftViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    private var invitation: String?
    private var searchCancellables = Set<AnyCancellable>()
    private let successSubject = PassthroughSubject<Contact, Never>()
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)
    private let stateSubject = CurrentValueSubject<SearchLeftViewState, Never>(.init())
    private var networkCancellable = Set<AnyCancellable>()

    init(_ invitation: String? = nil) {
        self.invitation = invitation
    }

    func viewDidAppear() {
        if let pendingInvitation = invitation {
            invitation = nil
            stateSubject.value.input = pendingInvitation
            hudSubject.send(.onAction(Localized.Ud.Search.cancel))

            networkCancellable.removeAll()

            networkMonitor.statusPublisher
                .first { $0 == .available }
                .eraseToAnyPublisher()
                .flatMap { _ in self.session.waitForNodes(timeout: 5) }
                .sink {
                    if case .failure(let error) = $0 {
                        self.hudSubject.send(.error(.init(with: error)))
                    }
                } receiveValue: {
                    self.didStartSearching()
                }.store(in: &networkCancellable)
        }
    }

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

//        backgroundScheduler.schedule { [weak self] in
//            guard let self = self else { return }

            do {
                let report = try SearchUD.live(
                    e2eId: self.e2e.getId(),
                    udContact: self.userDiscovery.getContact(),
                    facts: [Fact(fact: "teste", type: 0)],
                    callback: .init(handle: {
                        switch $0 {
                        case .success(let dataArray):
                            print("^^^ \(#file):\(#line) \(dataArray.map { $0.base64EncodedString() })")

                            // self.hudSubject.send(.none)
                            // self.appendToLocalSearch(contact)

                        case .failure(let error):
                            print("^^^ \(#file):\(#line) error: \(error.localizedDescription)")
                            self.appendToLocalSearch(nil)
                            self.hudSubject.send(.error(.init(with: error)))
                        }
                    })
                )

                print(report)
            } catch {
                print("^^^ \(#file):\(#line) error: \(error.localizedDescription)")
            }
//        }
    }

    func didTapResend(contact: Contact) {
        hudSubject.send(.on)

        var contact = contact
        contact.authStatus = .requesting

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.database.saveContact(contact)

                var myFacts = try self.userDiscovery.getFacts()
                myFacts.append(Fact(fact: self.username!, type: FactType.username.rawValue))

                let _ = try self.e2e.requestAuthenticatedChannel(
                    partnerContact: contact.id,
                    myFacts: myFacts
                )

                contact.authStatus = .requested
                contact = try self.database.saveContact(contact)

                self.hudSubject.send(.none)
            } catch {
                contact.authStatus = .requestFailed
                _ = try? self.database.saveContact(contact)
                self.hudSubject.send(.error(.init(with: error)))
            }
        }
    }

    func didTapRequest(contact: Contact) {
        hudSubject.send(.on)

        var contact = contact
        contact.nickname = contact.username
        contact.authStatus = .requesting

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.database.saveContact(contact)

                var myFacts = try self.userDiscovery.getFacts()
                myFacts.append(Fact(fact: self.username!, type: FactType.username.rawValue))

                let _ = try self.e2e.requestAuthenticatedChannel(
                    partnerContact: contact.marshaled!,
                    myFacts: myFacts
                )

                contact.authStatus = .requested
                contact = try self.database.saveContact(contact)

                self.hudSubject.send(.none)
                self.successSubject.send(contact)
            } catch {
                contact.authStatus = .requestFailed
                _ = try? self.database.saveContact(contact)
                self.hudSubject.send(.error(.init(with: error)))
            }
        }
    }

    func didSet(nickname: String, for contact: Contact) {
        if var contact = try? database.fetchContacts(.init(id: [contact.id])).first {
            contact.nickname = nickname
            _ = try? database.saveContact(contact)
        }
    }

    private func appendToLocalSearch(_ user: Contact?) {
        var snapshot = SearchSnapshot()

        if var user = user {
            if let contact = try? database.fetchContacts(.init(id: [user.id])).first {
                user.isBanned = contact.isBanned
                user.isBlocked = contact.isBlocked
                user.authStatus = contact.authStatus
            }

            if user.authStatus != .friend, !reportingStatus.isEnabled() {
                snapshot.appendSections([.stranger])
                snapshot.appendItems([.stranger(user)], toSection: .stranger)
            } else if user.authStatus != .friend, reportingStatus.isEnabled(), !user.isBanned, !user.isBlocked {
                snapshot.appendSections([.stranger])
                snapshot.appendItems([.stranger(user)], toSection: .stranger)
            }
        }

        let localsQuery = Contact.Query(
            text: stateSubject.value.input,
            authStatus: [.friend],
            isBlocked: reportingStatus.isEnabled() ? false : nil,
            isBanned: reportingStatus.isEnabled() ? false : nil
        )

        if let locals = try? database.fetchContacts(localsQuery),
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
        collection.filter { $0.id != myId }
    }
}
