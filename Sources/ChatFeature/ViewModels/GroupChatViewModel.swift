import UIKit
import Models
import Combine
import XXModels
import Foundation
import Integration
import DifferenceKit
import DependencyInjection

enum GroupChatNavigationRoutes: Equatable {
    case waitingRound
    case webview(String)
}

final class GroupChatViewModel {
    @Dependency private var session: SessionType

    var replyPublisher: AnyPublisher<(String, String), Never> {
        replySubject.eraseToAnyPublisher()
    }

    var routesPublisher: AnyPublisher<GroupChatNavigationRoutes, Never> {
        routesSubject.eraseToAnyPublisher()
    }

    let info: GroupInfo
    private var stagedReply: Reply?
    private var cancellables = Set<AnyCancellable>()
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

        return (contact.nickname ?? contact.username) ?? "Fetching username..."
    }

    func didRequestReply(_ message: Message) {
        guard let networkId = message.networkId else { return }
        stagedReply = Reply(messageId: networkId, senderId: message.senderId)
        replySubject.send(getReplyContent(for: networkId))
    }
}
