import HUD
import Retry
import UIKit
import Models
import Shared
import Combine
import XXModels
import XXClient
import Defaults
import Countries
import CustomDump
import ToastFeature
import NetworkMonitor
import ReportingFeature
import CombineSchedulers
import XXMessengerClient
import DependencyInjection

typealias SearchSnapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>

struct SearchLeftViewState {
    var input = ""
    var snapshot: SearchSnapshot?
    var country: Country = .fromMyPhone()
    var item: SearchSegmentedControl.Item = .username
}

final class SearchLeftViewModel {
    @Dependency var database: Database
    @Dependency var messenger: Messenger
    @Dependency var reportingStatus: ReportingStatus
    @Dependency var toastController: ToastController
    @Dependency var networkMonitor: NetworkMonitoring

    @KeyObject(.username, defaultValue: nil) var username: String?

    var myId: Data {
        try! messenger.e2e.get()!.getContact().getId()
    }

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var successPublisher: AnyPublisher<XXModels.Contact, Never> {
        successSubject.eraseToAnyPublisher()
    }

    var statePublisher: AnyPublisher<SearchLeftViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    private var invitation: String?
    private var searchCancellables = Set<AnyCancellable>()
    private let successSubject = PassthroughSubject<XXModels.Contact, Never>()
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

//            networkMonitor.statusPublisher
//                .first { $0 == .available }
//                .eraseToAnyPublisher()
//                .flatMap { _ in self.session.waitForNodes(timeout: 5) }
//                .sink {
//                    if case .failure(let error) = $0 {
//                        self.hudSubject.send(.error(.init(with: error)))
//                    }
//                } receiveValue: {
//                    self.didStartSearching()
//                }.store(in: &networkCancellable)
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

        if stateSubject.value.item == .phone {
            content += stateSubject.value.country.code
        }

        enum NodeRegistrationError: Error {
            case unhealthyNet
            case belowMinimum
        }

        retry(max: 5, retryStrategy: .delay(seconds: 2)) { [weak self] in
            guard let self = self else { return }

            do {
                let nrr = try self.messenger.cMix.get()!.getNodeRegistrationStatus()
                if nrr.ratio < 0.8 { throw NodeRegistrationError.belowMinimum }
            } catch {
                throw NodeRegistrationError.unhealthyNet
            }
        }.finalCatch { [weak self] in
            guard let self = self else { return }

            if case .unhealthyNet = $0 as? NodeRegistrationError {
                self.hudSubject.send(.error(.init(content: "Network is not healthy yet, try again within the next minute or so.")))
            } else if case .belowMinimum = $0 as? NodeRegistrationError {
                self.hudSubject.send(.error(.init(content: "Node registration ratio is still below 80%, try again within the next minute or so.")))
            } else {
                self.hudSubject.send(.error(.init(with: $0)))
            }

            return
        }

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                let report = try SearchUD.live(
                    e2eId: self.messenger.e2e.get()!.getId(),
                    udContact: self.messenger.ud.get()!.getContact(),
                    facts: [Fact(fact: content, type: self.stateSubject.value.item.rawValue)],
                    callback: .init(handle: {
                        switch $0 {
                        case .success(let results):
                             self.hudSubject.send(.none)
                             self.appendToLocalSearch(
                                XXModels.Contact(
                                    id: try! results.first!.getId(),
                                    marshaled: results.first!.data,
                                    username: try! results.first?.getFacts().first(where: { $0.type == FactType.username.rawValue })?.fact,
                                    email: try? results.first?.getFacts().first(where: { $0.type == FactType.email.rawValue })?.fact,
                                    phone: try? results.first?.getFacts().first(where: { $0.type == FactType.phone.rawValue })?.fact,
                                    nickname: nil,
                                    photo: nil,
                                    authStatus: .stranger,
                                    isRecent: true,
                                    isBlocked: false,
                                    isBanned: false,
                                    createdAt: Date()
                                )
                             )

                        case .failure(let error):
                            print("^^^ searchUD error: \(error.localizedDescription)")
                            self.appendToLocalSearch(nil)
                            self.hudSubject.send(.error(.init(with: error)))
                        }
                    })
                )

                print("^^^ report: \(report))")
            } catch {
                print("^^^ exception: \(error.localizedDescription)")
            }
        }
    }

    func didTapResend(contact: XXModels.Contact) {
        hudSubject.send(.on)

        var contact = contact
        contact.authStatus = .requesting

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.database.saveContact(contact)

                var myFacts = try self.messenger.ud.get()!.getFacts()
                myFacts.append(Fact(fact: self.username!, type: FactType.username.rawValue))

                let _ = try self.messenger.e2e.get()!.requestAuthenticatedChannel(
                    partner: .live(contact.marshaled!),
                    myFacts: myFacts
                )

                contact.authStatus = .requested
                contact = try self.database.saveContact(contact)

                self.hudSubject.send(.none)
                self.presentSuccessToast(for: contact, resent: true)
            } catch {
                contact.authStatus = .requestFailed
                _ = try? self.database.saveContact(contact)
                self.hudSubject.send(.error(.init(with: error)))
            }
        }
    }

    func didTapRequest(contact: XXModels.Contact) {
        hudSubject.send(.on)

        var contact = contact
        contact.nickname = contact.username
        contact.authStatus = .requesting

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.database.saveContact(contact)

                var myFacts = try self.messenger.ud.get()!.getFacts()
                myFacts.append(Fact(fact: self.username!, type: FactType.username.rawValue))

                let _ = try self.messenger.e2e.get()!.requestAuthenticatedChannel(
                    partner: .live(contact.marshaled!),
                    myFacts: myFacts
                )

                contact.authStatus = .requested
                contact = try self.database.saveContact(contact)

                self.hudSubject.send(.none)
                self.successSubject.send(contact)
                self.presentSuccessToast(for: contact, resent: false)
            } catch {
                contact.authStatus = .requestFailed
                _ = try? self.database.saveContact(contact)
                self.hudSubject.send(.error(.init(with: error)))
            }
        }
    }

    func didSet(nickname: String, for contact: XXModels.Contact) {
        if var contact = try? database.fetchContacts(.init(id: [contact.id])).first {
            contact.nickname = nickname
            _ = try? database.saveContact(contact)
        }
    }

    private func appendToLocalSearch(_ user: XXModels.Contact?) {
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

    private func removeMyself(from collection: [XXModels.Contact]) -> [XXModels.Contact]? {
        collection.filter { $0.id != myId }
    }

    private func presentSuccessToast(for contact: XXModels.Contact, resent: Bool) {
        let name = contact.nickname ?? contact.username
        let sentTitle = Localized.Requests.Sent.Toast.sent(name ?? "")
        let resentTitle = Localized.Requests.Sent.Toast.resent(name ?? "")

        toastController.enqueueToast(model: .init(
            title: resent ? resentTitle : sentTitle,
            leftImage: Asset.sharedSuccess.image
        ))
    }
}
