import UIKit
import Shared
import Combine
import XXModels
import Defaults
import AppCore
import Dependencies
import XXMessengerClient
import ReportingFeature

import struct XXModels.Group
import XXClient

enum SearchSection {
  case chats
  case connections
}

enum SearchItem: Equatable, Hashable {
  case chat(ChatInfo)
  case connection(XXModels.Contact)
}

typealias RecentsSnapshot = NSDiffableDataSourceSnapshot<SectionId, XXModels.Contact>
typealias SearchSnapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>

final class ChatListViewModel {
  @Dependency(\.app.dbManager) var dbManager
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.hudManager) var hudManager
  @Dependency(\.reportingStatus) var reportingStatus
  
  // TO REFACTOR:
  var isOnline: AnyPublisher<Bool, Never> {
    Just(.init(true)).eraseToAnyPublisher()
  }
  
  var myId: Data {
    try! messenger.e2e.get()!.getContact().getId()
  }
  
  var chatsPublisher: AnyPublisher<[ChatInfo], Never> {
    chatsSubject.eraseToAnyPublisher()
  }
  
  var recentsPublisher: AnyPublisher<RecentsSnapshot, Never> {
    let query = Contact.Query(
      authStatus: [.friend],
      isRecent: true,
      isBlocked: reportingStatus.isEnabled() ? false : nil,
      isBanned: reportingStatus.isEnabled() ? false : nil
    )
    
    return try! dbManager.getDB().fetchContactsPublisher(query)
      .replaceError(with: [])
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
      try! dbManager.getDB().fetchContactsPublisher(contactsQuery)
        .replaceError(with: [])
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
      try! dbManager.getDB().fetchContactsPublisher(contactsQuery).replaceError(with: []),
      try! dbManager.getDB().fetchGroupsPublisher(groupQuery).replaceError(with: [])
    )
    .map { $0.0.count + $0.1.count }
    .eraseToAnyPublisher()
  }
  
  private var cancellables = Set<AnyCancellable>()
  private let searchSubject = CurrentValueSubject<String, Never>("")
  private let chatsSubject = CurrentValueSubject<[ChatInfo], Never>([])
  
  init() {
    try! dbManager.getDB().fetchChatInfosPublisher(
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
    .replaceError(with: [])
    .sink { [unowned self] in chatsSubject.send($0) }
    .store(in: &cancellables)
  }
  
  func updateSearch(query: String) {
    searchSubject.send(query)
  }
  
  func leave(_ group: Group) {
    hudManager.show()
    do {
      try messenger.groupChat()!.leaveGroup(groupId: group.id)
      try dbManager.getDB().deleteMessages(.init(chat: .group(group.id)))
      try dbManager.getDB().deleteGroup(group)
      hudManager.hide()
    } catch {
      hudManager.show(.init(error: error))
    }
  }
  
  func clear(_ contact: XXModels.Contact) {
    _ = try? dbManager.getDB().deleteMessages(.init(chat: .direct(myId, contact.id)))
  }
  
  func groupInfo(from group: Group) -> GroupInfo? {
    let query = GroupInfo.Query(groupId: group.id)
    guard let info = try? dbManager.getDB().fetchGroupInfos(query).first else {
      return nil
    }
    
    return info
  }
}
