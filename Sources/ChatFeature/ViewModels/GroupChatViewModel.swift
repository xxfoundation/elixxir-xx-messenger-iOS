import HUD
import UIKit
import Models
import Shared
import Combine
import XXModels
import Defaults
import Foundation
import ToastFeature
import DifferenceKit
import ReportingFeature
import DependencyInjection
import XXMessengerClient

import struct XXModels.Message
import XXClient

enum GroupChatNavigationRoutes: Equatable {
    case waitingRound
    case webview(String)
}

final class GroupChatViewModel {
    @Dependency var database: Database
    @Dependency var sendReport: SendReport
    @Dependency var groupManager: GroupChat
    @Dependency var messenger: Messenger
    @Dependency var reportingStatus: ReportingStatus
    @Dependency var toastController: ToastController

    @KeyObject(.username, defaultValue: nil) var username: String?

    var myId: Data {
        try! messenger.e2e.get()!.getContact().getId()
    }

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
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
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)
    private let reportPopupSubject = PassthroughSubject<XXModels.Contact, Never>()
    private let replySubject = PassthroughSubject<(String, String), Never>()
    private let routesSubject = PassthroughSubject<GroupChatNavigationRoutes, Never>()

    var messages: AnyPublisher<[ArraySection<ChatSection, Message>], Never> {
        database.fetchMessagesPublisher(.init(chat: .group(info.group.id)))
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
        _ = try? database.bulkUpdateMessages(query, assignment)
    }

    func didRequestDelete(_ messages: [Message]) {
        _ = try? database.deleteMessages(.init(id: Set(messages.map(\.id))))
    }

    func didRequestReport(_ message: Message) {
        if let contact = try? database.fetchContacts(.init(id: [message.senderId])).first {
            reportPopupSubject.send(contact)
        }
    }

    func send(_ text: String) {
        var message = Message(
            senderId: myId,
            recipientId: nil,
            groupId: info.group.id,
            date: Date(),
            status: .sending,
            isUnread: false,
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            replyMessageId: stagedReply?.messageId
        )

        print("")
        print("Outgoing GroupMessage:")
        print("- groupId: \(info.group.id.base64EncodedString().prefix(10))...")
        print("- senderId: \(myId.base64EncodedString().prefix(10))...")
        print("- payload.text: \(message.text)")

        do {
            message = try database.saveMessage(message)

            let payload = Payload(
                text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                reply: stagedReply
            ).asData()

            let report = try groupManager.send(
                groupId: info.group.id,
                message: payload
            )

            print("- messageId: \(report.messageId.base64EncodedString().prefix(10))...")

            if let foo = stagedReply {
                print("- payload.reply.messageId: \(foo.messageId.base64EncodedString().prefix(10))...")
                print("- payload.reply.senderId: \(foo.senderId.base64EncodedString().prefix(10))...")
            } else {
                print("- payload.reply: ∅")
            }

            message.networkId = report.messageId

            try messenger.cMix.get()!.waitForRoundResult(
                roundList: try report.encode(),
                timeoutMS: 15_000,
                callback: .init(handle: {
                    switch $0 {
                    case .delivered:
                        message.status = .sent
                        if let foo = try? self.database.saveMessage(message) {
                            message = foo
                        }
                    case .notDelivered(timedOut: let timedOut):
                        if timedOut {
                            message.status = .sendingTimedOut
                        } else {
                            message.status = .sendingFailed
                        }

                        if let foo = try? self.database.saveMessage(message) {
                            message = foo
                        }
                    }
                })
            )

            print("")

            message.roundURL = report.roundURL
            message.date = Date.fromTimestamp(Int(report.timestamp))
            message = try database.saveMessage(message)
        } catch {
            message.status = .sendingFailed
            if let foo = try? database.saveMessage(message) {
                message = foo
            }
        }

        stagedReply = nil
    }

    func retry(_ message: Message) {
        var message = message

        do {
            message.status = .sending
            message = try database.saveMessage(message)

            var reply: Reply?

            if let replyId = message.replyMessageId {
                reply = Reply(messageId: replyId, senderId: myId)
            }

            let report = try groupManager.send(
                groupId: message.groupId!,
                message: Payload(
                    text: message.text,
                    reply: reply
                ).asData()
            )

            try messenger.cMix.get()!.waitForRoundResult(
                roundList: try report.encode(),
                timeoutMS: 15_000,
                callback: .init(handle: {
                    switch $0 {
                    case .delivered:
                        message.status = .sent
                        if let foo = try? self.database.saveMessage(message) {
                            message = foo
                        }
                    case .notDelivered(timedOut: let timedOut):
                        if timedOut {
                            message.status = .sendingTimedOut
                        } else {
                            message.status = .sendingFailed
                        }

                        if let foo = try? self.database.saveMessage(message) {
                            message = foo
                        }
                    }
                })
            )

            message.networkId = report.messageId
            message.date = Date.fromTimestamp(Int(report.timestamp))
            message = try database.saveMessage(message)
        } catch {
            message.status = .sendingFailed
            if let foo = try? database.saveMessage(message) {
                message = foo
            }
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
        guard let message = try? database.fetchMessages(.init(networkId: messageId)).first else {
            return ("[DELETED]", "[DELETED]")
        }

        return (getName(from: message.senderId), message.text)
    }

    func getName(from senderId: Data) -> String {
        guard senderId != myId else { return "You" }

        guard let contact = try? database.fetchContacts(.init(id: [senderId])).first else {
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

        hudSubject.send(.on)
        sendReport(report) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.hudSubject.send(.error(.init(with: error)))
                }

            case .success(_):
                self.blockContact(contact)
                DispatchQueue.main.async {
                    self.hudSubject.send(.none)
                    self.presentReportConfirmation(contact: contact)
                    completion()
                }
            }
        }
    }

    private func blockContact(_ contact: XXModels.Contact) {
        var contact = contact
        contact.isBlocked = true
        _ = try? database.saveContact(contact)
    }

    private func presentReportConfirmation(contact: XXModels.Contact) {
        let name = (contact.nickname ?? contact.username) ?? "the contact"
        toastController.enqueueToast(model: .init(
            title: "Your report has been sent and \(name) is now blocked.",
            leftImage: Asset.requestSentToaster.image
        ))
    }
}
