import HUD
import UIKit
import Shared
import Models
import Combine
import XXModels
import Defaults
import ReportingFeature
import DependencyInjection

import struct XXModels.Group
import XXClient

enum SearchSection {
    case chats
    case connections
}

enum SearchItem: Equatable, Hashable {
    case chat(ChatInfo)
    case connection(Contact)
}

typealias RecentsSnapshot = NSDiffableDataSourceSnapshot<SectionId, Contact>
typealias SearchSnapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>

final class ChatListViewModel {
    @Dependency var database: Database
    @Dependency var groupManager: GroupChat
    @Dependency var userDiscovery: UserDiscovery
    @Dependency var reportingStatus: ReportingStatus

    // TO REFACTOR:
    var isOnline: AnyPublisher<Bool, Never> {
        Just(.init(true)).eraseToAnyPublisher()
    }

    var myId: Data {
        try! GetIdFromContact.live(userDiscovery.getContact())
    }

    var chatsPublisher: AnyPublisher<[ChatInfo], Never> {
        chatsSubject.eraseToAnyPublisher()
    }

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var recentsPublisher: AnyPublisher<RecentsSnapshot, Never> {
        let query = Contact.Query(
            isRecent: true,
            isBlocked: reportingStatus.isEnabled() ? false : nil,
            isBanned: reportingStatus.isEnabled() ? false : nil
        )

        return database.fetchContactsPublisher(query)
            .assertNoFailure()
            .map {
                let section = SectionId()
                var snapshot = RecentsSnapshot()
                snapshot.appendSections([section])
                snapshot.appendItems($0, toSection: section)
                return snapshot
            }.eraseToAnyPublisher()
    }

    var searchPublisher: AnyPublisher<SearchSnapshot, Never> {
        let contactsQuery = Contact.Query(
            isBlocked: reportingStatus.isEnabled() ? false : nil,
            isBanned: reportingStatus.isEnabled() ? false : nil
        )

        return Publishers.CombineLatest3(
            database.fetchContactsPublisher(contactsQuery)
                .assertNoFailure()
                .map { $0.filter { $0.id != self.myId }},
            chatsPublisher,
            searchSubject
                .removeDuplicates()
                .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        )
        .map { (contacts, chats, query) in
            let connectionItems = contacts.filter {
                let username = $0.username?.lowercased().contains(query.lowercased()) ?? false
                let nickname = $0.nickname?.lowercased().contains(query.lowercased()) ?? false
                return username || nickname
            }.map(SearchItem.connection)

            let chatItems = chats.filter {
                switch $0 {
                case .group(let group):
                    return group.name.lowercased().contains(query.lowercased())

                case .groupChat(let info):
                    let name = info.group.name.lowercased().contains(query.lowercased())
                    let last = info.lastMessage.text.lowercased().contains(query.lowercased())
                    return name || last

                case .contactChat(let info):
                    let username = info.contact.username?.lowercased().contains(query.lowercased()) ?? false
                    let nickname = info.contact.nickname?.lowercased().contains(query.lowercased()) ?? false
                    let lastMessage = info.lastMessage.text.lowercased().contains(query.lowercased())
                    return username || nickname || lastMessage

                }
            }.map(SearchItem.chat)

            var snapshot = SearchSnapshot()

            if connectionItems.count > 0 {
                snapshot.appendSections([.connections])
                snapshot.appendItems(connectionItems, toSection: .connections)
            }

            if chatItems.count > 0 {
                snapshot.appendSections([.chats])
                snapshot.appendItems(chatItems, toSection: .chats)
            }

            return snapshot
        }.eraseToAnyPublisher()
    }

    var badgeCountPublisher: AnyPublisher<Int, Never> {
        let groupQuery = Group.Query(authStatus: [.pending])
        let contactsQuery = Contact.Query(
            authStatus: [
                .verified,
                .confirming,
                .confirmationFailed,
                .verificationFailed,
                .verificationInProgress
            ],
            isBlocked: reportingStatus.isEnabled() ? false : nil,
            isBanned: reportingStatus.isEnabled() ? false : nil
        )

        return Publishers.CombineLatest(
            database.fetchContactsPublisher(contactsQuery).assertNoFailure(),
            database.fetchGroupsPublisher(groupQuery).assertNoFailure()
        )
        .map { $0.0.count + $0.1.count }
        .eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = CurrentValueSubject<String, Never>("")
    private let chatsSubject = CurrentValueSubject<[ChatInfo], Never>([])
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)

    init() {
        database.fetchChatInfosPublisher(
            ChatInfo.Query(
                contactChatInfoQuery: .init(
                    userId: myId,
                    authStatus: [.friend],
                    isBlocked: reportingStatus.isEnabled() ? false : nil,
                    isBanned: reportingStatus.isEnabled() ? false : nil
                ),
                groupChatInfoQuery: GroupChatInfo.Query(
                    authStatus: [.participating],
                    excludeBannedContactsMessages: reportingStatus.isEnabled()
                ),
                groupQuery: Group.Query(
                    withMessages: false,
                    authStatus: [.participating]
                )
            ))
        .assertNoFailure()
        .sink { [unowned self] in chatsSubject.send($0) }
        .store(in: &cancellables)
    }

    func updateSearch(query: String) {
        searchSubject.send(query)
    }

    func leave(_ group: Group) {
        hudSubject.send(.on)

        do {
            try groupManager.leaveGroup(groupId: group.id)
            try database.deleteMessages(.init(chat: .group(group.id)))
            hudSubject.send(.none)
        } catch {
            hudSubject.send(.error(.init(with: error)))
        }
    }

    func clear(_ contact: Contact) {
        _ = try? database.deleteMessages(.init(chat: .direct(myId, contact.id)))
    }

    func groupInfo(from group: Group) -> GroupInfo? {
        let query = GroupInfo.Query(groupId: group.id)
        guard let info = try? database.fetchGroupInfos(query).first else {
            return nil
        }

        return info
    }
}
