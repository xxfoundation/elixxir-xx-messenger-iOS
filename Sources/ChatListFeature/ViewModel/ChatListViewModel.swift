import HUD
import UIKit
import Shared
import Models
import Combine
import Defaults
import Integration
import DependencyInjection

enum SearchSection {
    case chats
    case connections
}

enum SearchItem: Equatable, Hashable {
    case chat(Chat)
    case connection(Contact)
}

typealias RecentsSnapshot = NSDiffableDataSourceSnapshot<SectionId, Contact>
typealias SearchSnapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>

final class ChatListViewModel {
    @Dependency private var session: SessionType

    var isOnline: AnyPublisher<Bool, Never> {
        session.isOnline
    }

    var chatsPublisher: AnyPublisher<[Chat], Never> {
        chatsSubject.eraseToAnyPublisher()
    }

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var recentsPublisher: AnyPublisher<RecentsSnapshot, Never> {
        session.contacts(.isRecent).map {
            let section = SectionId()
            var snapshot = RecentsSnapshot()
            snapshot.appendSections([section])
            snapshot.appendItems($0, toSection: section)
            return snapshot
        }.eraseToAnyPublisher()
    }

    var searchPublisher: AnyPublisher<SearchSnapshot, Never> {
        Publishers.CombineLatest3(
            session.contacts(.all),
            chatsPublisher,
            searchSubject
                .removeDuplicates()
                .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        )
            .map { (contacts, chats, query) in
                let connectionItems = contacts.filter {
                    let username = $0.username.lowercased().contains(query.lowercased())
                    let nickname = $0.nickname?.lowercased().contains(query.lowercased()) ?? false
                    return username || nickname
                }.map(SearchItem.connection)

                let chatItems = chats.filter {
                    switch $0 {
                    case .contact(let info):
                        let username = info.contact.username.lowercased().contains(query.lowercased())
                        let nickname = info.contact.nickname?.lowercased().contains(query.lowercased()) ?? false
                        let lastMessage = info.lastMessage?.payload.text.lowercased().contains(query.lowercased()) ?? false
                        return username || nickname || lastMessage

                    case .group(let info):
                        let name = info.group.name.lowercased().contains(query.lowercased())
                        let last = info.lastMessage?.payload.text.lowercased().contains(query.lowercased()) ?? false
                        return name || last
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
        Publishers.CombineLatest(
            session.contacts(.received),
            session.groups(.pending)
        )
        .map { $0.0.count + $0.1.count }
        .eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = CurrentValueSubject<String, Never>("")
    private let chatsSubject = CurrentValueSubject<[Chat], Never>([])
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)

    init() {
        Publishers.CombineLatest(
            session.singleChats(.all),
            session.groupChats(.accepted)
        ).map {
            let groups = $0.1.map(Chat.group)
            let chats = $0.0.map(Chat.contact)
            return (chats + groups).sorted { $0.orderingDate > $1.orderingDate }
        }
        .sink { [unowned self] in chatsSubject.send($0) }
        .store(in: &cancellables)
    }

    func updateSearch(query: String) {
        searchSubject.send(query)
    }

    func leave(_ group: Group) {
        hudSubject.send(.on(nil))

        do {
            try session.leave(group: group)
            session.deleteAll(from: group)
            hudSubject.send(.none)
        } catch {
            hudSubject.send(.error(.init(with: error)))
        }
    }

    func clear(_ contact: Contact) {
        session.deleteAll(from: contact)
    }
}
