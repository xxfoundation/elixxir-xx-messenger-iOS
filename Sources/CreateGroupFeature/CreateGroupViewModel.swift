import Shared
import Combine
import AppCore
import XXModels
import InputField
import AppResources
import Dependencies

import Foundation // ?

struct CreateGroupViewModel {
  struct ViewState {
    var welcome: String?
    var groupName: String = ""
    var status: InputField.ValidationStatus = .unknown(nil)
    var shouldDismiss: Bool = false
  }

  @Dependency(\.app.bgQueue) var bgQueue
  @Dependency(\.app.dbManager) var dbManager
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.hudManager) var hudManager

  var statePublisher: AnyPublisher<ViewState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  private let stateSubject = CurrentValueSubject<ViewState, Never>(.init())

  func didInput(_ string: String) {
    stateSubject.value.groupName = string
    validate()
  }

  func didOtherInput(_ string: String) {
    stateSubject.value.welcome = string
  }

  func didTapCreate(_ members: [Contact]) {
    hudManager.show()
    let welcome = stateSubject.value.welcome
    let name = stateSubject.value.groupName.trimmingCharacters(in: .whitespacesAndNewlines)

    bgQueue.schedule {
      do {
        let report = try messenger.groupChat()!.makeGroup(
          membership: members.map(\.id),
          message: welcome?.data(using: .utf8),
          name: name.data(using: .utf8)
        )
        let group = Group(
          id: report.id,
          name: name,
          leaderId: try messenger.e2e.get()!.getContact().getId(),
          createdAt: Date(),
          authStatus: .participating,
          serialized: try report.encode()
        )
        try dbManager.getDB().saveGroup(group)
        if let welcome {
          try dbManager.getDB().saveMessage(.init(
            senderId: try messenger.e2e.get()!.getContact().getId(),
            recipientId: nil,
            groupId: group.id,
            date: group.createdAt,
            status: .sent,
            isUnread: false,
            text: welcome
          ))
        }
        try members.map {
          GroupMember(groupId: group.id, contactId: $0.id)
        }.forEach {
          try dbManager.getDB().saveGroupMember($0)
        }
        _ = try dbManager.getDB().fetchGroupInfos(
          .init(groupId: group.id)
        ).first
        hudManager.hide()
        stateSubject.value.shouldDismiss = true
      } catch {
        hudManager.show(.init(error: error))
      }
    }
  }

  private func validate() {
    let value = stateSubject.value.groupName.trimmingCharacters(in: .whitespacesAndNewlines)
    guard value.count >= 4 else {
      stateSubject.value.status = .invalid(Localized.CreateGroup.Drawer.minimum)
      return
    }
    guard value.count < 21 else {
      stateSubject.value.status = .invalid(Localized.CreateGroup.Drawer.maximum)
      return
    }
    stateSubject.value.status = .valid(nil)
  }
}
