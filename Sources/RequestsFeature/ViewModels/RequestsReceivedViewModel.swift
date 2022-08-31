import HUD
import UIKit
import Models
import Shared
import Combine
import Defaults
import XXModels
import XXClient
import DrawerFeature
import ReportingFeature
import CombineSchedulers
import DependencyInjection
import XXMessengerClient

import struct XXModels.Group

struct RequestReceived: Hashable, Equatable {
    var request: Request?
    var isHidden: Bool
    var leader: String?
}

final class RequestsReceivedViewModel {
    @Dependency var database: Database
    @Dependency var groupManager: GroupChat
    @Dependency var messenger: Messenger
    @Dependency var reportingStatus: ReportingStatus

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

    var contactConfirmationPublisher: AnyPublisher<XXModels.Contact, Never> {
        contactConfirmationSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let updateSubject = CurrentValueSubject<Void, Never>(())
    private let verifyingSubject = PassthroughSubject<Void, Never>()
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)
    private let groupConfirmationSubject = PassthroughSubject<Group, Never>()
    private let contactConfirmationSubject = PassthroughSubject<XXModels.Contact, Never>()
    private let itemsSubject = CurrentValueSubject<NSDiffableDataSourceSnapshot<Section, RequestReceived>, Never>(.init())

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    init() {
        let groupsQuery = Group.Query(
            authStatus: [
                .hidden,
                .pending
            ],
            isLeaderBlocked: reportingStatus.isEnabled() ? false : nil,
            isLeaderBanned: reportingStatus.isEnabled() ? false : nil
        )

        let contactsQuery = Contact.Query(
            authStatus: [
                .friend,
                .hidden,
                .verified,
                .verificationFailed,
                .verificationInProgress
            ],
            isBlocked: reportingStatus.isEnabled() ? false : nil,
            isBanned: reportingStatus.isEnabled() ? false : nil
        )

        let groupStream = database.fetchGroupsPublisher(groupsQuery).assertNoFailure()
        let contactsStream = database.fetchContactsPublisher(contactsQuery).assertNoFailure()

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
        guard case var .contact(contact) = request else { return }

        if request.status == .failedToVerify {
            backgroundScheduler.schedule { [weak self] in
                guard let self = self else { return }

                do {
                    contact.authStatus = .verificationInProgress
                    try self.database.saveContact(contact)

                    if contact.email == nil && contact.phone == nil {
                        let _ = try LookupUD.live(
                            e2eId: self.messenger.e2e.get()!.getId(),
                            udContact: self.messenger.ud.get()!.getContact(),
                            lookupId: contact.id,
                            callback: .init(handle: {
                                switch $0 {
                                case .success(let secondContact):
                                    let ownershipResult = try! self.messenger.e2e.get()!.verifyOwnership(
                                        received: XXClient.Contact.live(contact.marshaled!),
                                        verified: secondContact,
                                        e2eId: self.messenger.e2e.get()!.getId()
                                    )

                                    if ownershipResult == true {
                                        contact.authStatus = .verified
                                        _ = try? self.database.saveContact(contact)
                                    } else {
                                        _ = try? self.database.deleteContact(contact)
                                    }
                                case .failure(let error):
                                    print("^^^ \(#file):\(#line)  \(error.localizedDescription)")
                                    contact.authStatus = .verificationFailed
                                    _ = try? self.database.saveContact(contact)
                                }
                            })
                        )
                    } else {
                        let _ = try SearchUD.live(
                            e2eId: self.messenger.e2e.get()!.getId(),
                            udContact: self.messenger.ud.get()!.getContact(),
                            facts: XXClient.Contact.live(contact.marshaled!).getFacts(),
                            callback: .init(handle: {
                                switch $0 {
                                case .success(let results):
                                    let ownershipResult = try! self.messenger.e2e.get()!.verifyOwnership(
                                        received: XXClient.Contact.live(contact.marshaled!),
                                        verified: results.first!,
                                        e2eId: self.messenger.e2e.get()!.getId()
                                    )

                                    if ownershipResult == true {
                                        contact.authStatus = .verified
                                        _ = try? self.database.saveContact(contact)
                                    } else {
                                        _ = try? self.database.deleteContact(contact)
                                    }
                                case .failure(let error):
                                    print("^^^ \(#file):\(#line)  \(error.localizedDescription)")
                                    contact.authStatus = .verificationFailed
                                    _ = try? self.database.saveContact(contact)
                                }
                            })
                        )
                    }
                } catch {
                    print("^^^ \(#file):\(#line)  \(error.localizedDescription)")
                    contact.authStatus = .verificationFailed
                    _ = try? self.database.saveContact(contact)
                }
            }
        } else if request.status == .verifying {
            verifyingSubject.send()
        }
    }

    func didRequestHide(group: Group) {
        if var group = try? database.fetchGroups(.init(id: [group.id])).first {
            group.authStatus = .hidden
            _ = try? database.saveGroup(group)
        }
    }

    func didRequestAccept(group: Group) {
        hudSubject.send(.on)

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                let trackedId = try self.groupManager
                    .getGroup(groupId: group.id)
                    .getTrackedID()

                try self.groupManager.joinGroup(trackedGroupId: trackedId)

                var group = group
                group.authStatus = .participating
                try self.database.saveGroup(group)

                self.hudSubject.send(.none)
                self.groupConfirmationSubject.send(group)
            } catch {
                self.hudSubject.send(.error(.init(with: error)))
            }
        }
    }

    func fetchMembers(
        _ group: Group,
        _ completion: @escaping (Result<[DrawerTableCellModel], Error>) -> Void
    ) {
        if let info = try? database.fetchGroupInfos(.init(groupId: group.id)).first {
            database.fetchContactsPublisher(.init(id: Set(info.members.map(\.id))))
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

    func didRequestHide(contact: XXModels.Contact) {
        if var contact = try? database.fetchContacts(.init(id: [contact.id])).first {
            contact.authStatus = .hidden
            _ = try? database.saveContact(contact)
        }
    }

    func didRequestAccept(contact: XXModels.Contact, nickname: String? = nil) {
        hudSubject.send(.on)

        var contact = contact
        contact.authStatus = .confirming
        contact.nickname = nickname ?? contact.username

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                try self.database.saveContact(contact)

                let _ = try self.messenger.e2e.get()!.confirmReceivedRequest(partner: .live(contact.marshaled!))
                contact.authStatus = .friend
                try self.database.saveContact(contact)

                self.hudSubject.send(.none)
                self.contactConfirmationSubject.send(contact)
            } catch {
                contact.authStatus = .confirmationFailed
                _ = try? self.database.saveContact(contact)
                self.hudSubject.send(.error(.init(with: error)))
            }
        }
    }

    func groupChatWith(group: Group) -> GroupInfo {
        guard let info = try? database.fetchGroupInfos(.init(groupId: group.id)).first else {
            fatalError()
        }

        return info
    }
}
