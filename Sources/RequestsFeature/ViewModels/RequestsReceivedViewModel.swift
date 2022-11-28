import UIKit
import Shared
import AppCore
import Combine
import Defaults
import XXModels
import XXClient
import Dependencies
import DrawerFeature
import ReportingFeature
import CombineSchedulers
import XXMessengerClient

import struct XXModels.Group

struct RequestReceived: Hashable, Equatable {
  var request: Request?
  var isHidden: Bool
  var leader: String?
}

final class RequestsReceivedViewModel {
  @Dependency(\.app.dbManager) var dbManager
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.app.hudManager) var hudManager
  @Dependency(\.reportingStatus) var reportingStatus
  
  @KeyObject(.isShowingHiddenRequests, defaultValue: false) var isShowingHiddenRequests: Bool

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
    
    let groupStream = try! dbManager.getDB()
      .fetchGroupsPublisher(groupsQuery)
      .replaceError(with: [])
    
    let contactsStream = try! dbManager.getDB()
      .fetchContactsPublisher(contactsQuery)
      .replaceError(with: [])
    
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
        guard let self else { return }
        
        do {
          contact.authStatus = .verificationInProgress
          try self.dbManager.getDB().saveContact(contact)
          
          print(">>> [messenger.verifyContact] will start")
          
          if try self.messenger.verifyContact(XXClient.Contact.live(contact.marshaled!)) {
            print(">>> [messenger.verifyContact] verified")
            
            contact.authStatus = .verified
            contact = try self.dbManager.getDB().saveContact(contact)
          } else {
            print(">>> [messenger.verifyContact] is fake")
            
            try self.dbManager.getDB().deleteContact(contact)
          }
        } catch {
          print(">>> [messenger.verifyContact] thrown an exception: \(error.localizedDescription)")
          
          contact.authStatus = .verificationFailed
          _ = try? self.dbManager.getDB().saveContact(contact)
        }
      }
    } else if request.status == .verifying {
      verifyingSubject.send()
    }
  }
  
  func didRequestHide(group: Group) {
    if var group = try? dbManager.getDB().fetchGroups(.init(id: [group.id])).first {
      group.authStatus = .hidden
      _ = try? dbManager.getDB().saveGroup(group)
    }
  }
  
  func didRequestAccept(group: Group) {
    hudManager.show()
    
    backgroundScheduler.schedule { [weak self] in
      guard let self else { return }
      
      do {
        try self.messenger.groupChat()!.joinGroup(serializedGroupData: group.serialized)

        var group = group
        group.authStatus = .participating
        try self.dbManager.getDB().saveGroup(group)
        
        self.hudManager.hide()
        self.groupConfirmationSubject.send(group)
      } catch {
        self.hudManager.show(.init(error: error))
      }
    }
  }
  
  func fetchMembers(
    _ group: Group,
    _ completion: @escaping (Result<[DrawerTableCellModel], Error>) -> Void
  ) {
    if let info = try? dbManager.getDB().fetchGroupInfos(.init(groupId: group.id)).first {
      try! dbManager.getDB().fetchContactsPublisher(.init(id: Set(info.members.map(\.id))))
        .replaceError(with: [])
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
    if var contact = try? dbManager.getDB().fetchContacts(.init(id: [contact.id])).first {
      contact.authStatus = .hidden
      _ = try? dbManager.getDB().saveContact(contact)
    }
  }
  
  func didRequestAccept(contact: XXModels.Contact, nickname: String? = nil) {
    hudManager.show()
    
    var contact = contact
    contact.authStatus = .confirming
    contact.nickname = nickname ?? contact.username
    
    backgroundScheduler.schedule { [weak self] in
      guard let self else { return }
      
      do {
        try self.dbManager.getDB().saveContact(contact)
        
        let _ = try self.messenger.e2e.get()!.confirmReceivedRequest(partner: .live(contact.marshaled!))
        contact.authStatus = .friend
        try self.dbManager.getDB().saveContact(contact)
        
        self.hudManager.hide()
        self.contactConfirmationSubject.send(contact)
      } catch {
        contact.authStatus = .confirmationFailed
        _ = try? self.dbManager.getDB().saveContact(contact)
        self.hudManager.show(.init(error: error))
      }
    }
  }
  
  func groupChatWith(group: Group) -> GroupInfo {
    guard let info = try? dbManager.getDB().fetchGroupInfos(.init(groupId: group.id)).first else {
      fatalError()
    }
    
    return info
  }
}
