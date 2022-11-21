import UIKit
import Shared
import AppCore
import Combine
import XXModels
import Defaults
import Foundation
import AppResources
import DifferenceKit
import ReportingFeature
import XXMessengerClient
import ComposableArchitecture

import struct XXModels.Message
import XXClient

enum GroupChatNavigationRoutes: Equatable {
  case waitingRound
  case webview(String)
}

final class GroupChatViewModel {
  @Dependency(\.sendReport) var sendReport
  @Dependency(\.app.dbManager) var dbManager
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.app.hudManager) var hudManager
  @Dependency(\.app.toastManager) var toastManager
  @Dependency(\.reportingStatus) var reportingStatus

  @KeyObject(.username, defaultValue: nil) var username: String?

  var myId: Data {
    try! messenger.e2e.get()!.getContact().getId()
  }

  var reportPopupPublisher: AnyPublisher<XXModels.Contact, Never> {
    reportPopupSubject.eraseToAnyPublisher()
  }

  var replyPublisher: AnyPublisher<(String, String), Never> {
    replySubject.eraseToAnyPublisher()
  }

  var routesPublisher: AnyPublisher<GroupChatNavigationRoutes, Never> {
    routesSubject.eraseToAnyPublisher()
  }

  let info: GroupInfo
  private var stagedReply: Reply?
  private var cancellables = Set<AnyCancellable>()
  private let reportPopupSubject = PassthroughSubject<XXModels.Contact, Never>()
  private let replySubject = PassthroughSubject<(String, String), Never>()
  private let routesSubject = PassthroughSubject<GroupChatNavigationRoutes, Never>()

  var messages: AnyPublisher<[ArraySection<ChatSection, Message>], Never> {
    try! dbManager.getDB().fetchMessagesPublisher(.init(chat: .group(info.group.id)))
      .replaceError(with: [])
      .map { messages -> [ArraySection<ChatSection, Message>] in
        let groupedByDate = Dictionary(grouping: messages) { domainModel -> Date in
          let components = Calendar.current.dateComponents([.day, .month, .year], from: domainModel.date)
          return Calendar.current.date(from: components)!
        }

        return groupedByDate
          .map { .init(model: ChatSection(date: $0.key), elements: $0.value) }
          .sorted(by: { $0.model.date < $1.model.date })
      }
      .map { sections -> [ArraySection<ChatSection, Message>] in
        var snapshot = [ArraySection<ChatSection, Message>]()
        sections.forEach { snapshot.append(.init(model: $0.model, elements: $0.elements)) }
        return snapshot
      }.eraseToAnyPublisher()
  }

  init(_ info: GroupInfo) {
    self.info = info
  }

  func readAll() {
    let assignment = Message.Assignments(isUnread: false)
    let query = Message.Query(chat: .group(info.group.id))
    _ = try? dbManager.getDB().bulkUpdateMessages(query, assignment)
  }

  func didRequestDelete(_ messages: [Message]) {
    _ = try? dbManager.getDB().deleteMessages(.init(id: Set(messages.map(\.id))))
  }

  func didRequestReport(_ message: Message) {
    if let contact = try? dbManager.getDB().fetchContacts(.init(id: [message.senderId])).first {
      reportPopupSubject.send(contact)
    }
  }

  func send(_ text: String) {
    do {
      var message = Message(
        senderId: try messenger.e2e.get()!.getContact().getId(),
        recipientId: nil,
        groupId: info.group.id,
        date: Date(),
        status: .sending,
        isUnread: false,
        text: text.trimmingCharacters(in: .whitespacesAndNewlines),
        replyMessageId: stagedReply?.messageId
      )
      message = try dbManager.getDB().saveMessage(message)
      let report = try messenger.groupChat()!.send(
        groupId: info.id,
        message: MessagePayload(
          text: text.trimmingCharacters(in: .whitespacesAndNewlines),
          replyingTo: stagedReply?.messageId
        ).encode()
      )
      message.networkId = report.messageId
      message.date = Date.fromTimestamp(Int(report.timestamp))
      message = try dbManager.getDB().saveMessage(message)
      try messenger.cMix.get()?.waitForRoundResult(
        roundList: try report.encode(),
        timeoutMS: 15_000,
        callback: .init(handle: { result in
          switch result {
          case .delivered:
            message.status = .sent
          case .notDelivered(timedOut: let timedOut):
            message.status = timedOut ? .sendingTimedOut : .sendingFailed
          }
          _ = try? self.dbManager.getDB().saveMessage(message)
        })
      )
    } catch {
      print(error.localizedDescription)
    }
  }

  func retry(_ message: Message) {
    do {
      var message = message
      message.status = .sending
      message = try dbManager.getDB().saveMessage(message)
      let report = try messenger.groupChat()!.send(
        groupId: info.id,
        message: MessagePayload(
          text: message.text.trimmingCharacters(in: .whitespacesAndNewlines),
          replyingTo: stagedReply?.messageId
        ).encode()
      )
      message.networkId = report.messageId
      message.date = Date.fromTimestamp(Int(report.timestamp))
      message = try dbManager.getDB().saveMessage(message)
      try messenger.cMix.get()?.waitForRoundResult(
        roundList: try report.encode(),
        timeoutMS: 15_000,
        callback: .init(handle: { result in
          switch result {
          case .delivered:
            message.status = .sent
          case .notDelivered(timedOut: let timedOut):
            message.status = timedOut ? .sendingTimedOut : .sendingFailed
          }
          _ = try? self.dbManager.getDB().saveMessage(message)
        })
      )
    } catch {
      print(error.localizedDescription)
    }
  }

  func showRoundFrom(_ roundURL: String?) {
    if let urlString = roundURL, !urlString.isEmpty {
      routesSubject.send(.webview(urlString))
    } else {
      routesSubject.send(.waitingRound)
    }
  }

  func abortReply() {
    stagedReply = nil
  }

  func getReplyContent(for messageId: Data) -> (String, String) {
    guard let message = try? dbManager.getDB().fetchMessages(.init(networkId: messageId)).first else {
      return ("[DELETED]", "[DELETED]")
    }

    return (getName(from: message.senderId), message.text)
  }

  func getName(from senderId: Data) -> String {
    guard senderId != myId else { return "You" }

    guard let contact = try? dbManager.getDB().fetchContacts(.init(id: [senderId])).first else {
      return "[DELETED]"
    }

    var name = (contact.nickname ?? contact.username) ?? "Fetching username..."

    if contact.isBlocked, reportingStatus.isEnabled() {
      name = "\(name) (Blocked)"
    }

    return name
  }

  func didRequestReply(_ message: Message) {
    guard let networkId = message.networkId else { return }
    stagedReply = Reply(messageId: networkId, senderId: message.senderId)
    replySubject.send(getReplyContent(for: networkId))
  }

  func report(contact: XXModels.Contact, screenshot: UIImage, completion: @escaping () -> Void) {
    let report = Report(
      sender: .init(
        userId: contact.id.base64EncodedString(),
        username: contact.username!
      ),
      recipient: .init(
        userId: myId.base64EncodedString(),
        username: username!
      ),
      type: .group,
      screenshot: screenshot.pngData()!,
      partyName: info.group.name,
      partyBlob: info.group.id.base64EncodedString(),
      partyMembers: info.members.map { Report.ReportUser(
        userId: $0.id.base64EncodedString(),
        username: $0.username ?? "")
      }
    )

    hudManager.show()
    sendReport(report) { result in
      switch result {
      case .failure(let error):
        DispatchQueue.main.async {
          self.hudManager.show(.init(error: error))
        }

      case .success(_):
        self.blockContact(contact)
        DispatchQueue.main.async {
          self.hudManager.hide()
          self.presentReportConfirmation(contact: contact)
          completion()
        }
      }
    }
  }

  private func blockContact(_ contact: XXModels.Contact) {
    var contact = contact
    contact.isBlocked = true
    _ = try? dbManager.getDB().saveContact(contact)
  }

  private func presentReportConfirmation(contact: XXModels.Contact) {
    let name = (contact.nickname ?? contact.username) ?? "the contact"
    toastManager.enqueue(.init(
      title: "Your report has been sent and \(name) is now blocked.",
      leftImage: Asset.requestSentToaster.image
    ))
  }
}
