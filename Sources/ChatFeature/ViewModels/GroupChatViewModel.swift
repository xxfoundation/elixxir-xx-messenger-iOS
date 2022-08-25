import HUD
import UIKit
import Models
import Shared
import Combine
import XXModels
import Defaults
import Foundation
import Integration
import ToastFeature
import DifferenceKit
import ReportingFeature
import DependencyInjection

enum GroupChatNavigationRoutes: Equatable {
    case waitingRound
    case webview(String)
}

final class GroupChatViewModel {
    @Dependency private var session: SessionType
    @Dependency private var sendReport: SendReport
    @Dependency private var reportingStatus: ReportingStatus
    @Dependency private var toastController: ToastController

    @KeyObject(.username, defaultValue: nil) var username: String?

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var reportPopupPublisher: AnyPublisher<Contact, Never> {
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
    private let reportPopupSubject = PassthroughSubject<Contact, Never>()
    private let replySubject = PassthroughSubject<(String, String), Never>()
    private let routesSubject = PassthroughSubject<GroupChatNavigationRoutes, Never>()

    var messages: AnyPublisher<[ArraySection<ChatSection, Message>], Never> {
        session.dbManager.fetchMessagesPublisher(.init(chat: .group(info.group.id)))
            .assertNoFailure()
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
        _ = try? session.dbManager.bulkUpdateMessages(query, assignment)
    }

    func didRequestDelete(_ messages: [Message]) {
        _ = try? session.dbManager.deleteMessages(.init(id: Set(messages.map(\.id))))
    }

    func didRequestReport(_ message: Message) {
        if let contact = try? session.dbManager.fetchContacts(.init(id: [message.senderId])).first {
            reportPopupSubject.send(contact)
        }
    }

    func send(_ text: String) {
        session.send(.init(
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            reply: stagedReply
        ), toGroup: info.group)
        stagedReply = nil
    }

    func retry(_ message: Message) {
        guard let id = message.id else { return }
        session.retryMessage(id)
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
        guard let message = try? session.dbManager.fetchMessages(.init(networkId: messageId)).first else {
            return ("[DELETED]", "[DELETED]")
        }

        return (getName(from: message.senderId), message.text)
    }

    func getName(from senderId: Data) -> String {
        guard senderId != session.myId else { return "You" }

        guard let contact = try? session.dbManager.fetchContacts(.init(id: [senderId])).first else {
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

    func report(contact: Contact, screenshot: UIImage, completion: @escaping () -> Void) {
        let report = Report(
            sender: .init(
                userId: contact.id.base64EncodedString(),
                username: contact.username!
            ),
            recipient: .init(
                userId: session.myId.base64EncodedString(),
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

    private func blockContact(_ contact: Contact) {
        var contact = contact
        contact.isBlocked = true
        _ = try? session.dbManager.saveContact(contact)
    }

    private func presentReportConfirmation(contact: Contact) {
        let name = (contact.nickname ?? contact.username) ?? "the contact"
        toastController.enqueueToast(model: .init(
            title: "Your report has been sent and \(name) is now blocked.",
            leftImage: Asset.requestSentToaster.image
        ))
    }
}
