import HUD
import UIKit
import Models
import Shared
import Combine
import Defaults
import XXModels
import Integration
import DrawerFeature
import CombineSchedulers
import DependencyInjection

struct RequestReceived: Hashable, Equatable {
    var request: Request?
    var isHidden: Bool
    var leader: String?
}

final class RequestsReceivedViewModel {
    @Dependency private var session: SessionType

    @KeyObject(.isShowingHiddenRequests, defaultValue: false) var isShowingHiddenRequests: Bool

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var verifyingPublisher: AnyPublisher<Void, Never> {
        verifyingSubject.eraseToAnyPublisher()
    }

    var itemsPublisher: AnyPublisher<NSDiffableDataSourceSnapshot<Section, RequestReceived>, Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    var groupConfirmationPublisher: AnyPublisher<Group, Never> {
        groupConfirmationSubject.eraseToAnyPublisher()
    }

    var contactConfirmationPublisher: AnyPublisher<Contact, Never> {
        contactConfirmationSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let updateSubject = CurrentValueSubject<Void, Never>(())
    private let verifyingSubject = PassthroughSubject<Void, Never>()
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)
    private let groupConfirmationSubject = PassthroughSubject<Group, Never>()
    private let contactConfirmationSubject = PassthroughSubject<Contact, Never>()
    private let itemsSubject = CurrentValueSubject<NSDiffableDataSourceSnapshot<Section, RequestReceived>, Never>(.init())

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    init() {
        let groupsQuery = Group.Query(
            authStatus: [
                .hidden,
                .pending
            ])

        let contactsQuery = Contact.Query(
            authStatus: [
                .friend,
                .hidden,
                .verified,
                .verificationFailed,
                .verificationInProgress
            ])

        let groupStream = session.dbManager.fetchGroupsPublisher(groupsQuery).assertNoFailure()
        let contactsStream = session.dbManager.fetchContactsPublisher(contactsQuery).assertNoFailure()

        Publishers.CombineLatest3(
            groupStream,
            contactsStream,
            updateSubject.eraseToAnyPublisher()
        )
        .subscribe(on: DispatchQueue.main)
        .receive(on: DispatchQueue.global())
        .map { [unowned self] data -> NSDiffableDataSourceSnapshot<Section, RequestReceived> in
            var snapshot = NSDiffableDataSourceSnapshot<Section, RequestReceived>()
            snapshot.appendSections([.appearing, .hidden])

            let contactsFilteringFriends = data.1.filter { $0.authStatus != .friend }
            let requests = data.0.map(Request.group) + contactsFilteringFriends.map(Request.contact)
            let receivedRequests = requests.map { request -> RequestReceived in
                switch request {
                case let .group(group):
                    func leaderName() -> String {
                        if let leader = data.1.first(where: { $0.id == group.leaderId }) {
                            return (leader.nickname ?? leader.username) ?? "Leader is not a friend"
                        } else {
                            return "[Error retrieving leader]"
                        }
                    }

                    return RequestReceived(
                        request: request,
                        isHidden: group.authStatus == .hidden,
                        leader: leaderName()
                    )
                case let .contact(contact):
                    return RequestReceived(
                        request: request,
                        isHidden: contact.authStatus == .hidden,
                        leader: nil
                    )
                }
            }

            if self.isShowingHiddenRequests {
                snapshot.appendItems(receivedRequests.filter(\.isHidden), toSection: .hidden)
            }

            guard receivedRequests.filter({ $0.isHidden == false }).count > 0 else {
                snapshot.appendItems([RequestReceived(isHidden: false)], toSection: .appearing)
                return snapshot
            }

            snapshot.appendItems(receivedRequests.filter { $0.isHidden == false }, toSection: .appearing)
            return snapshot
        }.sink(
            receiveCompletion: { _ in },
            receiveValue: { [unowned self] in itemsSubject.send($0) }
        ).store(in: &cancellables)
    }

    func didToggleHiddenRequestsSwitcher() {
        isShowingHiddenRequests.toggle()
        updateSubject.send()
    }

    func didTapStateButtonFor(request: Request) {
        guard case let .contact(contact) = request else { return }

        if request.status == .failedToVerify {
            backgroundScheduler.schedule { [weak self] in
                self?.session.verify(contact: contact)
            }
        } else if request.status == .verifying {
            verifyingSubject.send()
        }
    }

    func didRequestHide(group: Group) {
        if var group = try? session.dbManager.fetchGroups(.init(id: [group.id])).first {
            group.authStatus = .hidden
            _ = try? session.dbManager.saveGroup(group)
        }
    }

    func didRequestAccept(group: Group) {
        hudSubject.send(.on)

        backgroundScheduler.schedule { [weak self] in
            do {
                try self?.session.join(group: group)
                self?.hudSubject.send(.none)
                self?.groupConfirmationSubject.send(group)
            } catch {
                self?.hudSubject.send(.error(.init(with: error)))
            }
        }
    }

    func fetchMembers(
        _ group: Group,
        _ completion: @escaping (Result<[DrawerTableCellModel], Error>) -> Void
    ) {
        if let info = try? session.dbManager.fetchGroupInfos(.init(groupId: group.id)).first {
            session.dbManager.fetchContactsPublisher(.init(id: Set(info.members.map(\.id))))
                .assertNoFailure()
                .sink { members in
                    let withUsername = members
                        .filter { $0.username != nil }
                        .map {
                            DrawerTableCellModel(
                                id: $0.id,
                                title: $0.nickname ?? $0.username!,
                                image: $0.photo,
                                isCreator: $0.id == group.leaderId,
                                isConnection: $0.authStatus == .friend
                            )
                        }

                    let withoutUsername = members
                        .filter { $0.username == nil }
                        .map {
                            DrawerTableCellModel(
                                id: $0.id,
                                title: "Fetching username...",
                                image: $0.photo,
                                isCreator: $0.id == group.leaderId,
                                isConnection: $0.authStatus == .friend
                            )
                        }

                    completion(.success(withUsername + withoutUsername))
                }.store(in: &cancellables)
        }
    }

    func didRequestHide(contact: Contact) {
        if var contact = try? session.dbManager.fetchContacts(.init(id: [contact.id])).first {
            contact.authStatus = .hidden
            _ = try? session.dbManager.saveContact(contact)
        }
    }

    func didRequestAccept(contact: Contact, nickname: String? = nil) {
        hudSubject.send(.on)

        var contact = contact
        contact.nickname = nickname ?? contact.username

        backgroundScheduler.schedule { [weak self] in
            do {
                try self?.session.confirm(contact)
                self?.hudSubject.send(.none)
                self?.contactConfirmationSubject.send(contact)
            } catch {
                self?.hudSubject.send(.error(.init(with: error)))
            }
        }
    }

    func groupChatWith(group: Group) -> GroupInfo {
        guard let info = try? session.dbManager.fetchGroupInfos(.init(groupId: group.id)).first else {
            fatalError()
        }

        return info
    }
}
