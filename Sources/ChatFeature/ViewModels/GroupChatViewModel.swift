import UIKit
import Models
import Combine
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

    var replyPublisher: AnyPublisher<ReplyModel, Never> {
        replySubject.eraseToAnyPublisher()
    }

    var routesPublisher: AnyPublisher<GroupChatNavigationRoutes, Never> {
        routesSubject.eraseToAnyPublisher()
    }

    let info: GroupChatInfo
    private var stagedReply: Reply?
    private var cancellables = Set<AnyCancellable>()
    private let replySubject = PassthroughSubject<ReplyModel, Never>()
    private let routesSubject = PassthroughSubject<GroupChatNavigationRoutes, Never>()

    var messages: AnyPublisher<[ArraySection<ChatSection, GroupChatItem>], Never> {
        session.groupMessages(info.group)
            .map { messages -> [ArraySection<ChatSection, GroupChatItem>] in
                let domainModels = messages.map { GroupChatItem($0) }
                let groupedByDate = Dictionary(grouping: domainModels) { domainModel -> Date in
                    let components = Calendar.current.dateComponents([.day, .month, .year], from: domainModel.date)
                    return Calendar.current.date(from: components)!
                }

                return groupedByDate
                    .map { .init(model: ChatSection(date: $0.key), elements: $0.value) }
                    .sorted(by: { $0.model.date < $1.model.date })
            }
            .map { sections -> [ArraySection<ChatSection, GroupChatItem>] in
            var snapshot = [ArraySection<ChatSection, GroupChatItem>]()
            sections.forEach { snapshot.append(.init(model: $0.model, elements: $0.elements)) }
            return snapshot
        }.eraseToAnyPublisher()
    }

    init(_ info: GroupChatInfo) {
        self.info = info
    }

    func readAll() {
        session.readAll(from: info.group)
    }

    func didRequestDelete(_ items: [GroupChatItem]) {
        session.delete(groupMessages: items.map { $0.identity })
    }

    func send(_ text: String) {
        session.send(.init(
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            reply: stagedReply,
            attachment: nil
        ), toGroup: info.group)
        stagedReply = nil
    }

    func retry(_ model: GroupChatItem) {
        session.retryGroupMessage(model.identity)
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

    func getName(from senderId: Data) -> String {
        guard let member = info.members.first(where: { $0.userId == senderId }) else { return "You" }
        return member.username
    }

    func getText(from messageId: Data) -> String {
        session.getTextFromGroupMessage(messageId: messageId) ?? "[DELETED]"
    }

    func didRequestReply(_ model: GroupChatItem) {
        guard let messageId = model.uniqueId else { return }

        stagedReply = Reply(messageId: messageId, senderId: model.sender)
        replySubject.send(.init(text: model.payload.text, sender: getName(from: model.sender)))
    }
}
