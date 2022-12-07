import UIKit
import Shared
import AppCore
import Combine
import XXModels
import XXClient
import Defaults
import AppResources
import Dependencies
import AppNavigation
import DifferenceKit
import ReportingFeature
import XXMessengerClient
import PermissionsFeature

import struct XXModels.Message
import struct XXModels.FileTransfer

enum SingleChatNavigationRoutes: Equatable {
  case none
  case camera
  case library
  case waitingRound
  case cameraPermission
  case libraryPermission
  case microphonePermission
  case webview(String)
}

final class SingleChatViewModel: NSObject {
  @Dependency(\.sendReport) var sendReport
  @Dependency(\.permissions) var permissions
  @Dependency(\.app.dbManager) var dbManager
  @Dependency(\.app.sendImage) var sendImage
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.hudManager) var hudManager
  @Dependency(\.app.sendMessage) var sendMessage
  @Dependency(\.app.toastManager) var toastManager
  @Dependency(\.app.networkMonitor) var networkMonitor

  @KeyObject(.username, defaultValue: nil) var username: String?
  
  var contact: XXModels.Contact { contactSubject.value }
  private var stagedReply: Reply?
  private var cancellables = Set<AnyCancellable>()
  private let contactSubject: CurrentValueSubject<XXModels.Contact, Never>
  private let replySubject = PassthroughSubject<(String, String), Never>()
  private let navigationRoutes = PassthroughSubject<SingleChatNavigationRoutes, Never>()
  private let sectionsRelay = CurrentValueSubject<[ArraySection<ChatSection, Message>], Never>([])
  private let reportPopupSubject = PassthroughSubject<Void, Never>()
  
  private var healthCancellable: XXClient.Cancellable?
  
  var isOnline: AnyPublisher<Bool, Never> {
    networkMonitor
      .observeStatus()
      .map { $0 == .available }
      .eraseToAnyPublisher()
  }

  var myId: Data {
    try! messenger.e2e.get()!.getContact().getId()
  }
  
  var contactPublisher: AnyPublisher<XXModels.Contact, Never> { contactSubject.eraseToAnyPublisher() }
  var replyPublisher: AnyPublisher<(String, String), Never> { replySubject.eraseToAnyPublisher() }
  var navigation: AnyPublisher<SingleChatNavigationRoutes, Never> { navigationRoutes.eraseToAnyPublisher() }
  var shouldDisplayEmptyView: AnyPublisher<Bool, Never> { sectionsRelay.map { $0.isEmpty }.eraseToAnyPublisher() }
  
  var reportPopupPublisher: AnyPublisher<Void, Never> {
    reportPopupSubject.eraseToAnyPublisher()
  }
  
  var messages: AnyPublisher<[ArraySection<ChatSection, Message>], Never> {
    sectionsRelay.map { sections -> [ArraySection<ChatSection, Message>] in
      var snapshot = [ArraySection<ChatSection, Message>]()
      sections.forEach { snapshot.append(.init(model: $0.model, elements: $0.elements)) }
      return snapshot
    }.eraseToAnyPublisher()
  }
  
  private func updateRecentState(_ contact: XXModels.Contact) {
    if contact.isRecent == true {
      var contact = contact
      contact.isRecent = false
      _ = try? dbManager.getDB().saveContact(contact)
    }
  }
  
  func viewDidAppear() {
    updateRecentState(contact)
  }
  
  init(_ contact: XXModels.Contact) {
    self.contactSubject = .init(contact)
    super.init()
    
    updateRecentState(contact)
    
    try! dbManager.getDB().fetchContactsPublisher(Contact.Query(id: [contact.id]))
      .replaceError(with: [])
      .compactMap { $0.first }
      .sink { [unowned self] in contactSubject.send($0) }
      .store(in: &cancellables)
    
    try! dbManager.getDB().fetchMessagesPublisher(.init(chat: .direct(myId, contact.id)))
      .replaceError(with: [])
      .map {
        let groupedByDate = Dictionary(grouping: $0) { domainModel -> Date in
          let components = Calendar.current.dateComponents([.day, .month, .year], from: domainModel.date)
          return Calendar.current.date(from: components)!
        }
        
        return groupedByDate
          .map { .init(model: ChatSection(date: $0.key), elements: $0.value) }
          .sorted(by: { $0.model.date < $1.model.date })
      }.receive(on: DispatchQueue.main)
      .sink { [unowned self] in sectionsRelay.send($0) }
      .store(in: &cancellables)
    
    healthCancellable = messenger.cMix.get()!.addHealthCallback(.init(handle: { [weak self] in
      guard let self else { return }
      self.networkMonitor.update($0)
    }))
  }
  
  func getFileTransferWith(id: Data) -> FileTransfer {
    guard let transfer = try? dbManager.getDB().fetchFileTransfers(.init(id: [id])).first else {
      fatalError()
    }
    
    return transfer
  }
  
  func didSendAudio(url: URL) {}
  
  func didSend(image: UIImage) {
    guard let imageData = image.orientedUp().jpegData(compressionQuality: 1.0) else { return }

    sendImage(imageData, to: contact.id, onError: {
      print("\($0.localizedDescription)")
    }) {
      print("finished")
    }
  }

  func readAll() {
    let assignment = Message.Assignments(isUnread: false)
    let query = Message.Query(chat: .direct(myId, contact.id))
    _ = try? dbManager.getDB().bulkUpdateMessages(query, assignment)
  }

  func didRequestDeleteAll() {
    _ = try? dbManager.getDB().deleteMessages(.init(chat: .direct(myId, contact.id)))
  }

  func didRequestRetry(_ message: Message) {
    // TODO
  }

  func didNavigateSomewhere() {
    navigationRoutes.send(.none)
  }

  @discardableResult
  func didTest(permission: PermissionType) -> Bool {
    switch permission {
    case .camera:
      if permissions.camera.status() {
        navigationRoutes.send(.camera)
      } else {
        navigationRoutes.send(.cameraPermission)
      }
    case .library:
      if permissions.library.status() {
        navigationRoutes.send(.library)
      } else {
        navigationRoutes.send(.libraryPermission)
      }
    case .microphone:
      if permissions.microphone.status() {
        return true
      } else {
        navigationRoutes.send(.microphonePermission)
      }
    }

    return false
  }

  func didRequestCopy(_ model: Message) {
    UIPasteboard.general.string = model.text
  }

  func didRequestDeleteSingle(_ model: Message) {
    didRequestDelete([model])
  }

  func didRequestReport(_: Message) {
    reportPopupSubject.send()
  }

  func abortReply() {
    stagedReply = nil
  }

  func send(_ string: String) {
    sendMessage(
      text: string.trimmingCharacters(in: .whitespacesAndNewlines),
      replyingTo: stagedReply?.messageId,
      to: contact.id,
      onError: {
        print("\($0.localizedDescription)")
      }, completion: {
        print("completed")
      }
    )
  }

  func didRequestReply(_ message: Message) {
    guard let networkId = message.networkId else { return }

    let senderTitle: String = {
      if message.senderId == myId {
        return "You"
      } else {
        return (contact.nickname ?? contact.username) ?? "Fetching username..."
      }
    }()

    replySubject.send((senderTitle, message.text))
    stagedReply = Reply(messageId: networkId, senderId: message.senderId)
  }

  func getReplyContent(for messageId: Data) -> (String, String) {
    guard let message = try? dbManager.getDB().fetchMessages(.init(networkId: messageId)).first else {
      return ("[DELETED]", "[DELETED]")
    }

    guard let contact = try? dbManager.getDB().fetchContacts(.init(id: [message.senderId])).first else {
      fatalError()
    }

    let contactTitle = (contact.nickname ?? contact.username) ?? "You"
    return (contactTitle, message.text)
  }

  func showRoundFrom(_ roundURL: String?) {
    if let urlString = roundURL, !urlString.isEmpty {
      navigationRoutes.send(.webview(urlString))
    } else {
      navigationRoutes.send(.waitingRound)
    }
  }

  func didRequestDelete(_ items: [Message]) {
    _ = try? dbManager.getDB().deleteMessages(.init(id: Set(items.compactMap(\.id))))
  }

  func itemWith(id: Int64) -> Message? {
    sectionsRelay.value.flatMap(\.elements).first(where: { $0.id == id })
  }

  func itemAt(indexPath: IndexPath) -> Message? {
    guard sectionsRelay.value.count > indexPath.section else { return nil }

    let items = sectionsRelay.value[indexPath.section].elements
    return items.count > indexPath.row ? items[indexPath.row] : nil
  }

  func section(at index: Int) -> ChatSection? {
    sectionsRelay.value.count > 0 ? sectionsRelay.value[index].model : nil
  }

  func report(screenshot: UIImage, completion: @escaping (Bool) -> Void) {
    let report = Report(
      sender: .init(
        userId: contact.id.base64EncodedString(),
        username: contact.username!
      ),
      recipient: .init(
        userId: myId.base64EncodedString(),
        username: username!
      ),
      type: .dm,
      screenshot: screenshot.pngData()!
    )

    hudManager.show()
    sendReport(report) { result in
      switch result {
      case .failure(let error):
        DispatchQueue.main.async {
          self.hudManager.show(.init(error: error))
          completion(false)
        }

      case .success(_):
        self.blockContact()
        DispatchQueue.main.async {
          self.hudManager.hide()
          self.presentReportConfirmation()
          completion(true)
        }
      }
    }
  }

  private func blockContact() {
    var contact = contact
    contact.isBlocked = true
    _ = try? dbManager.getDB().saveContact(contact)
  }

  private func presentReportConfirmation() {
    let name = (contact.nickname ?? contact.username) ?? "the contact"
    toastManager.enqueue(.init(
      title: "Your report has been sent and \(name) is now blocked.",
      leftImage: Asset.requestSentToaster.image
    ))
  }
}
