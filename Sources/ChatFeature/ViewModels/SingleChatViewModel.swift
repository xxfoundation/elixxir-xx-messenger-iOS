import UIKit
import Shared
import Combine
import XXLogger
import XXModels
import XXClient
import Defaults
import Foundation
import Permissions
import DifferenceKit
import ReportingFeature
import DI
import XXMessengerClient

import struct XXModels.Message
import struct XXModels.FileTransfer
import NetworkMonitor

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
  @Dependency var logger: XXLogger
  @Dependency var database: Database
  @Dependency var messenger: Messenger
  @Dependency var sendReport: SendReport
  @Dependency var hudController: HUDController
  @Dependency var permissions: PermissionHandling
  @Dependency var toastController: ToastController
  @Dependency var networkMonitor: NetworkMonitoring
  @Dependency var transferManager: XXClient.FileTransfer
  
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
      .statusPublisher
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
      _ = try? database.saveContact(contact)
    }
  }
  
  func viewDidAppear() {
    updateRecentState(contact)
  }
  
  init(_ contact: XXModels.Contact) {
    self.contactSubject = .init(contact)
    super.init()
    
    updateRecentState(contact)
    
    database.fetchContactsPublisher(Contact.Query(id: [contact.id]))
      .replaceError(with: [])
      .compactMap { $0.first }
      .sink { [unowned self] in contactSubject.send($0) }
      .store(in: &cancellables)
    
    database.fetchMessagesPublisher(.init(chat: .direct(myId, contact.id)))
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
  
  // MARK: Public
  
  func getFileTransferWith(id: Data) -> FileTransfer {
    guard let transfer = try? database.fetchFileTransfers(.init(id: [id])).first else {
      fatalError()
    }
    
    return transfer
  }
  
  func didSendAudio(url: URL) {
//    do {
//      let _ = try transferManager.send(
//        params: .init(
//          payload: .init(
//            name: "",
//            type: "",
//            preview: Data(),
//            contents: Data()
//          ),
//          recipientId: contact.id,
//          retry: 1,
//          period: 1_000
//        ),
//        callback: .init(handle: {
//          switch $0 {
//          case .success(let progressCallback):
//            print(progressCallback.progress.total)
//          case .failure(let error):
//            print(error.localizedDescription)
//          }
//        })
//      )
//
//      // transferId
//    } catch {
//
//    }
  }
  
  func didSend(image: UIImage) {
    guard let imageData = image.orientedUp().jpegData(compressionQuality: 1.0) else { return }
    hudController.show()
    
    let transferName = UUID().uuidString
    
    do {
//      let tid = try transferManager.send(
//        params: .init(
//          payload: .init(
//            name: transferName,
//            type: "jpeg",
//            preview: Data(),
//            contents: imageData
//          ),
//          recipientId: contact.id,
//          retry: 10,
//          period: 1_000
//        ),
//        callback: .init(handle: {
//          switch $0 {
//          case .success(let progressCallback):
//
//            if progressCallback.progress.completed {
//              print(">>> Outgoing transfer finished successfully")
//            } else {
//              print(">>> Outgoing transfer. (\(progressCallback.progress.transmitted)/\(progressCallback.progress.total))")
//            }
//
//            /// THIS IS TOO COMPLEX, NEEDS HELP FROM DARIUSZ
//
//          case .failure(let error):
//            print(">>> Transfer.error: \(error.localizedDescription)")
//          }
//        })
////      )
//      
//      let transferModel = FileTransfer(
//        id: tid,
//        contactId: contact.id,
//        name: transferName,
//        type: "jpeg",
//        data: imageData,
//        progress: 0.0,
//        isIncoming: false,
//        createdAt: Date()
//      )
//      
//      let transferMessage = Message(
//        senderId: myId,
//        recipientId: contact.id,
//        groupId: nil,
//        date: Date(),
//        status: .sending,
//        isUnread: false,
//        text: "",
//        replyMessageId: nil,
//        roundURL: nil,
//        fileTransferId: tid
//      )
//      
//      try database.saveFileTransfer(transferModel)
//      try database.saveMessage(transferMessage)
      
      hudController.dismiss()
    } catch {
      hudController.show(.init(error: error))
    }
  }
  
  func readAll() {
    let assignment = Message.Assignments(isUnread: false)
    let query = Message.Query(chat: .direct(myId, contact.id))
    _ = try? database.bulkUpdateMessages(query, assignment)
  }
  
  func didRequestDeleteAll() {
    _ = try? database.deleteMessages(.init(chat: .direct(myId, contact.id)))
  }
  
  func didRequestRetry(_ message: Message) {
    var message = message
    
    do {
      message.status = .sending
      message = try database.saveMessage(message)
      
      var reply: Reply?
      
      if let replyId = message.replyMessageId {
        reply = Reply(messageId: replyId, senderId: myId)
      }
      
      let report = try messenger.e2e.get()!.send(
        messageType: 2,
        recipientId: contact.id,
        payload: Payload(
          text: message.text,
          reply: reply
        ).asData(),
        e2eParams: GetE2EParams.liveDefault()
      )
      
      try messenger.cMix.get()!.waitForRoundResult(
        roundList: try report.encode(),
        timeoutMS: 15_000,
        callback: .init(handle: {
          switch $0 {
          case .delivered:
            message.status = .sent
            _ = try? self.database.saveMessage(message)
            
          case .notDelivered(timedOut: let timedOut):
            if timedOut {
              message.status = .sendingTimedOut
            } else {
              message.status = .sendingFailed
            }
            
            _ = try? self.database.saveMessage(message)
          }
        })
      )
      
      message.roundURL = report.roundURL
      message.networkId = report.messageId
      if let timestamp = report.timestamp {
        message.date = Date.fromTimestamp(Int(timestamp))
      }
      
      message = try database.saveMessage(message)
    } catch {
      print(error.localizedDescription)
      message.status = .sendingFailed
      _ = try? database.saveMessage(message)
    }
  }
  
  func didNavigateSomewhere() {
    navigationRoutes.send(.none)
  }
  
  @discardableResult
  func didTest(permission: PermissionType) -> Bool {
    switch permission {
    case .camera:
      if permissions.isCameraAllowed {
        navigationRoutes.send(.camera)
      } else {
        navigationRoutes.send(.cameraPermission)
      }
    case .library:
      if permissions.isPhotosAllowed {
        navigationRoutes.send(.library)
      } else {
        navigationRoutes.send(.libraryPermission)
      }
    case .microphone:
      if permissions.isMicrophoneAllowed {
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
    var message: Message = .init(
      senderId: myId,
      recipientId: contact.id,
      groupId: nil,
      date: Date(),
      status: .sending,
      isUnread: false,
      text: string.trimmingCharacters(in: .whitespacesAndNewlines),
      replyMessageId: stagedReply?.messageId
    )
    
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      
      do {
        message = try self.database.saveMessage(message)
        
        let report = try self.messenger.e2e.get()!.send(
          messageType: 2,
          recipientId: self.contact.id,
          payload: Payload(text: message.text, reply: self.stagedReply).asData(),
          e2eParams: GetE2EParams.liveDefault()
        )
        
        try self.messenger.cMix.get()!.waitForRoundResult(
          roundList: try report.encode(),
          timeoutMS: 15_000,
          callback: .init(handle: {
            switch $0 {
            case .delivered:
              message.status = .sent
              _ = try? self.database.saveMessage(message)
              
            case .notDelivered(timedOut: let timedOut):
              if timedOut {
                message.status = .sendingTimedOut
              } else {
                message.status = .sendingFailed
              }
              
              _ = try? self.database.saveMessage(message)
            }
          })
        )
        
        message.roundURL = report.roundURL
        message.networkId = report.messageId
        if let timestamp = report.timestamp {
          message.date = Date.fromTimestamp(Int(timestamp))
        }
        
        message = try self.database.saveMessage(message)
      } catch {
        print(error.localizedDescription)
        message.status = .sendingFailed
        _ = try? self.database.saveMessage(message)
      }
      
      self.stagedReply = nil
    }
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
    guard let message = try? database.fetchMessages(.init(networkId: messageId)).first else {
      return ("[DELETED]", "[DELETED]")
    }
    
    guard let contact = try? database.fetchContacts(.init(id: [message.senderId])).first else {
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
    _ = try? database.deleteMessages(.init(id: Set(items.compactMap(\.id))))
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
    
    hudController.show()
    sendReport(report) { result in
      switch result {
      case .failure(let error):
        DispatchQueue.main.async {
          self.hudController.show(.init(error: error))
          completion(false)
        }
        
      case .success(_):
        self.blockContact()
        DispatchQueue.main.async {
          self.hudController.dismiss()
          self.presentReportConfirmation()
          completion(true)
        }
      }
    }
  }
  
  private func blockContact() {
    var contact = contact
    contact.isBlocked = true
    _ = try? database.saveContact(contact)
  }
  
  private func presentReportConfirmation() {
    let name = (contact.nickname ?? contact.username) ?? "the contact"
    toastController.enqueueToast(model: .init(
      title: "Your report has been sent and \(name) is now blocked.",
      leftImage: Asset.requestSentToaster.image
    ))
  }
}
