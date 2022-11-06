import UIKit
import Shared
import Combine
import XXModels
import Defaults
import XXClient
import ReportingFeature
import CombineSchedulers
import XXMessengerClient
import DependencyInjection

final class CreateGroupViewModel {
  @KeyObject(.username, defaultValue: "") var username: String

  @Dependency var database: Database
  @Dependency var messenger: Messenger
  @Dependency var groupManager: GroupChat
  @Dependency var hudController: HUDController
  @Dependency var reportingStatus: ReportingStatus

  var myId: Data {
    try! messenger.e2e.get()!.getContact().getId()
  }

  var selected: AnyPublisher<[XXModels.Contact], Never> {
    selectedContactsRelay.eraseToAnyPublisher()
  }

  var contacts: AnyPublisher<[XXModels.Contact], Never> {
    contactsRelay.eraseToAnyPublisher()
  }

  var info: AnyPublisher<GroupInfo, Never> {
    infoRelay.eraseToAnyPublisher()
  }

  var backgroundScheduler: AnySchedulerOf<DispatchQueue>
  = DispatchQueue.global().eraseToAnyScheduler()

  private var allContacts = [XXModels.Contact]()
  private var cancellables = Set<AnyCancellable>()
  private let infoRelay = PassthroughSubject<GroupInfo, Never>()
  private let contactsRelay = CurrentValueSubject<[XXModels.Contact], Never>([])
  private let selectedContactsRelay = CurrentValueSubject<[XXModels.Contact], Never>([])

  init() {
    let query = Contact.Query(
      authStatus: [.friend],
      isBlocked: reportingStatus.isEnabled() ? false : nil,
      isBanned: reportingStatus.isEnabled() ? false : nil
    )

    database.fetchContactsPublisher(query)
      .replaceError(with: [])
      .map { $0.filter { $0.id != self.myId }}
      .map { $0.sorted(by: { $0.username! < $1.username! })}
      .sink { [unowned self] in
        allContacts = $0
        contactsRelay.send($0)
      }.store(in: &cancellables)
  }

  // MARK: Public

  func didSelect(contact: XXModels.Contact) {
    if selectedContactsRelay.value.contains(contact) {
      selectedContactsRelay.value.removeAll { $0.username == contact.username }
    } else {
      selectedContactsRelay.value.append(contact)
    }
  }

  func filter(_ text: String) {
    guard text.isEmpty == false else {
      contactsRelay.send(allContacts)
      return
    }

    contactsRelay.send(
      allContacts.filter {
        ($0.username ?? "").contains(text.lowercased())
      }
    )
  }

  func create(name: String, welcome: String?, members: [XXModels.Contact]) {
    hudController.show()

    backgroundScheduler.schedule { [weak self] in
      guard let self = self else { return }

      do {
        let report = try self.groupManager.makeGroup(
          membership: members.map(\.id),
          message: welcome?.data(using: .utf8),
          name: name.data(using: .utf8)
        )

        let group = Group(
          id: report.id,
          name: name,
          leaderId: self.myId,
          createdAt: Date(),
          authStatus: .participating,
          serialized: try report.encode() // ?
        )

        _ = try self.database.saveGroup(group)

        if let welcomeMessage = welcome {
          try self.database.saveMessage(
            Message(
              senderId: self.myId,
              recipientId: nil,
              groupId: group.id,
              date: group.createdAt,
              status: .sent,
              isUnread: false,
              text: welcomeMessage,
              replyMessageId: nil,
              roundURL: nil,
              fileTransferId: nil
            )
          )
        }

        try members
          .map { GroupMember(groupId: group.id, contactId: $0.id) }
          .forEach { try self.database.saveGroupMember($0) }

        let query = GroupInfo.Query(groupId: group.id)
        let info = try self.database.fetchGroupInfos(query).first

        self.infoRelay.send(info!)
        self.hudController.dismiss()
      } catch {
        self.hudController.show(.init(error: error))
      }
    }
  }
}
