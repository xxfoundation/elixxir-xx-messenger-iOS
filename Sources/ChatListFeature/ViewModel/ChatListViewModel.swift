import HUD
import Shared
import Models
import Combine
import Defaults
import Foundation
import Integration
import DependencyInjection

protocol ChatListViewModelType {
    var myId: Data { get }
    var username: String { get }
    var editState: EditStateHandler { get }
    var searchQueryRelay: CurrentValueSubject<String, Never> { get }
    var chatsRelay: CurrentValueSubject<[GenericChatInfo], Never> { get }

    var isOnline: AnyPublisher<Bool, Never> { get }
    var badgeCount: AnyPublisher<Int, Never> { get }

    func delete(indexPaths: [IndexPath]?)
}

final class ChatListViewModel: ChatListViewModelType {
    @Dependency private var session: SessionType

    @KeyObject(.username, defaultValue: "") var myUsername: String

    let editState = EditStateHandler()
    let chatsRelay = CurrentValueSubject<[GenericChatInfo], Never>([])
    let searchQueryRelay = CurrentValueSubject<String, Never>("")
    private var cancellables = Set<AnyCancellable>()

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var badgeCount: AnyPublisher<Int, Never> {
        Publishers.CombineLatest(
            session.contacts(.received),
            session.groups(.pending)
        ).map { $0.0.count + $0.1.count }
        .eraseToAnyPublisher()
    }

    var isOnline: AnyPublisher<Bool, Never> { session.isOnline }

    var myId: Data { session.myId }

    var username: String { myUsername }

    init() {
        let searchStream = searchQueryRelay
            .removeDuplicates()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()

        Publishers.CombineLatest3(
            session.singleChats(.all),
            session.groupChats(.accepted),
            searchStream
        ).map { data -> [GenericChatInfo] in
            let singles = data.0
            let groupies = data.1
            let searched = data.2

            var generics = [GenericChatInfo]()

            for single in singles {
                generics.append(
                    GenericChatInfo(
                        contact: single.contact,
                        groupInfo: nil,
                        latestE2EMessage: single.lastMessage
                    )
                )
            }

            for group in groupies {
                generics.append(
                    GenericChatInfo(
                        contact: nil,
                        groupInfo: group,
                        latestE2EMessage: nil
                    )
                )
            }

            if !searched.isEmpty {
                generics = generics.filter { filtering in
                    if let contact = filtering.contact {
                        let username = contact.username.lowercased().contains(searched.lowercased())
                        let nickname = contact.nickname?.lowercased().contains(searched.lowercased()) ?? false
                        let lastMessage = filtering.latestE2EMessage?.payload.text.lowercased().contains(searched.lowercased()) ?? false

                        return username || nickname || lastMessage
                    } else {
                        if let group = filtering.groupInfo?.group {
                            let name = group.name.lowercased().contains(searched.lowercased())
                            let last = filtering.groupInfo?.lastMessage?.payload.text.lowercased().contains(searched.lowercased()) ?? false
                            return name || last
                        }
                    }

                    return false
                }
            }

            #warning("TODO: Use enum to differentiate chats")

            return generics.sorted { infoA, infoB in
                if let singleA = infoA.latestE2EMessage {
                    if let singleB = infoB.latestE2EMessage {
                        /// aSingle bSingle
                        return singleA.timestamp > singleB.timestamp
                    } else {
                        /// aSingle bGroup
                        let groupB = infoB.groupInfo!

                        if let lastGM = groupB.lastMessage {
                            /// aSingle bGroup w/ message
                            return singleA.timestamp > lastGM.timestamp
                        } else {
                            /// aSingle bGroup w/out message
                            return true
                        }
                    }
                } else {
                    let groupA = infoA.groupInfo!

                    if let lastGM = groupA.lastMessage {
                        /// aGroup w/ message

                        if let singleB = infoB.latestE2EMessage {
                            /// aGroup w/ message bSingle

                            return lastGM.timestamp > singleB.timestamp
                        } else {
                            let groupB = infoB.groupInfo!
                            /// aGroup w/ message bGroup

                            if let lastGM2 = groupB.lastMessage {
                                return lastGM.timestamp > lastGM2.timestamp
                            } else {
                                return true
                            }
                        }
                    } else {
                        /// aGroup w/out message b?
                        return false
                    }
                }
            }
        }.sink { [unowned self] in chatsRelay.send($0)  }
        .store(in: &cancellables)
    }

    func isGroup(indexPath: IndexPath) -> Bool {
        chatsRelay.value[indexPath.row].contact == nil
    }

    func deleteAndLeaveGroupFrom(indexPath: IndexPath) {
        guard let group = chatsRelay.value[indexPath.row].groupInfo?.group else {
            fatalError("Tried to delete a group from an index path that is not one")
        }

        do {
            hudRelay.send(.on(nil))
            try session.leave(group: group)
            hudRelay.send(.none)
        } catch {
            hudRelay.send(.error(.init(with: error)))
        }
    }

    func delete(indexPaths: [IndexPath]?) {
        guard let selectedIndexPaths = indexPaths else {
            let contacts = chatsRelay.value.compactMap { $0.contact }
            let groups = chatsRelay.value.compactMap { $0.groupInfo?.group }

            groups.forEach(session.deleteAll(from:))
            contacts.forEach(session.deleteAll(from:))
            return
        }

        let contacts = selectedIndexPaths.compactMap { chatsRelay.value[$0.row].contact }
        let groups = selectedIndexPaths.compactMap { chatsRelay.value[$0.row].groupInfo?.group }

        groups.forEach(session.deleteAll(from:))
        contacts.forEach(session.deleteAll(from:))
    }
}
