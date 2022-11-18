import Combine
import AppCore
import XXModels
import Defaults
import Foundation
import Dependencies
import ReportingFeature

final class GroupDraftViewModel {
  @Dependency(\.app.bgQueue) var bgQueue
  @Dependency(\.app.dbManager) var dbManager
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.reportingStatus) var reportingStatus

  @KeyObject(.username, defaultValue: "") var username: String

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

    try! dbManager.getDB().fetchContactsPublisher(query)
      .replaceError(with: [])
      .map { $0.filter { $0.id != self.myId }}
      .map { $0.sorted(by: { $0.username! < $1.username! })}
      .sink { [unowned self] in
        allContacts = $0
        contactsRelay.send($0)
      }.store(in: &cancellables)
  }

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
}
