import HUD
import UIKit
import Models
import Shared
import Combine
import XXLogger
import XXModels
import Foundation
import Integration
import Permissions
import DifferenceKit
import DependencyInjection

struct ReplyModel {
    var text: String
    var sender: String
}

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

final class SingleChatViewModel {
    @Dependency private var logger: XXLogger
    @Dependency private var session: SessionType
    @Dependency private var permissions: PermissionHandling

    var contact: Contact { contactSubject.value }
    private var stagedReply: Reply?
    private var cancellables = Set<AnyCancellable>()
    private let contactSubject: CurrentValueSubject<Contact, Never>
    private let replySubject = PassthroughSubject<ReplyModel, Never>()
    private let navigationRoutes = PassthroughSubject<SingleChatNavigationRoutes, Never>()
    private let sectionsRelay = CurrentValueSubject<[ArraySection<ChatSection, ChatItem>], Never>([])

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var isOnline: AnyPublisher<Bool, Never> { session.isOnline }
    var contactPublisher: AnyPublisher<Contact, Never> { contactSubject.eraseToAnyPublisher() }
    var replyPublisher: AnyPublisher<ReplyModel, Never> { replySubject.eraseToAnyPublisher() }
    var navigation: AnyPublisher<SingleChatNavigationRoutes, Never> { navigationRoutes.eraseToAnyPublisher() }
    var shouldDisplayEmptyView: AnyPublisher<Bool, Never> { sectionsRelay.map { $0.isEmpty }.eraseToAnyPublisher() }

    var messages: AnyPublisher<[ArraySection<ChatSection, ChatItem>], Never> {
        sectionsRelay.map { sections -> [ArraySection<ChatSection, ChatItem>] in
            var snapshot = [ArraySection<ChatSection, ChatItem>]()
            sections.forEach { snapshot.append(.init(model: $0.model, elements: $0.elements)) }
            return snapshot
        }.eraseToAnyPublisher()
    }

    private func updateRecentState(_ contact: Contact) {
        if contact.isRecent == true {
            var contact = contact
            contact.isRecent = false
            session.update(contact)
        }
    }

    func viewDidAppear() {
        updateRecentState(contact)
    }

    init(_ contact: Contact) {
        self.contactSubject = .init(contact)

        updateRecentState(contact)

        session.contacts(.withUserId(contact.userId))
            .compactMap { $0.first }
            .sink { [unowned self] in contactSubject.send($0) }
            .store(in: &cancellables)

        session.singleMessages(contact)
            .map { $0.sorted(by: { $0.timestamp < $1.timestamp }) }
            .map { messages in

                let domainModels = messages.map { ChatItem($0) }
                let groupedByDate = Dictionary(grouping: domainModels) { domainModel -> Date in
                    let components = Calendar.current.dateComponents([.day, .month, .year], from: domainModel.date)
                    return Calendar.current.date(from: components)!
                }

                return groupedByDate
                    .map { .init(model: ChatSection(date: $0.key), elements: $0.value) }
                    .sorted(by: { $0.model.date < $1.model.date })
            }.receive(on: DispatchQueue.main)
            .sink { [unowned self] in sectionsRelay.send($0) }
            .store(in: &cancellables)
    }

    // MARK: Public

    func didSendAudio(url: URL) {
        let name = url.deletingPathExtension().lastPathComponent
        guard let file = FileManager.retrieve(name: name, type: Attachment.Extension.audio.written) else { return }

        let attachment = Attachment(name: name, data: file, _extension: .audio)
        let payload = Payload(text: "You sent a voice message", reply: nil, attachment: attachment)
        session.send(payload, toContact: contact)
    }

    func didSend(image: UIImage) {
        guard let imageData = image.orientedUp().jpegData(compressionQuality: 1.0) else { return }
        hudRelay.send(.on(nil))

        session.send(imageData: imageData, to: contact) { [weak self] in
            switch $0 {
            case .success:
                self?.hudRelay.send(.none)
            case .failure(let error):
                self?.hudRelay.send(.error(.init(with: error)))
            }
        }
    }

    func readAll() {
        session.readAll(from: contact)
    }

    func didRequestDeleteAll() {
        session.deleteAll(from: contact)
    }

    func didRequestRetry(_ model: ChatItem) {
        session.retryMessage(model.identity)
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

    func didRequestCopy(_ model: ChatItem) {
        UIPasteboard.general.string = model.payload.text
    }

    func didRequestDeleteSingle(_ model: ChatItem) {
        didRequestDelete([model])
    }

    func abortReply() {
        stagedReply = nil
    }

    func send(_ string: String) {
        let text = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let payload = Payload(text: text, reply: stagedReply, attachment: nil)
        session.send(payload, toContact: contact)
        stagedReply = nil
    }

    func didRequestReply(_ model: ChatItem) {
        guard let messageId = model.uniqueId else { return }

        let isIncoming = model.status == .received || model.status == .read
        stagedReply = Reply(messageId: messageId, senderId: isIncoming ? contact.userId : session.myId)
        replySubject.send(.init(text: model.payload.text, sender: isIncoming ? contact.nickname ?? contact.username : "You"))
    }

    func getText(from messageId: Data) -> String {
        session.getTextFromMessage(messageId: messageId) ?? "[DELETED]"
    }

    func showRoundFrom(_ roundURL: String?) {
        if let urlString = roundURL, !urlString.isEmpty {
            navigationRoutes.send(.webview(urlString))
        } else {
            navigationRoutes.send(.waitingRound)
        }
    }

    func didRequestDelete(_ items: [ChatItem]) {
        session.delete(messages: items.map { $0.identity })
    }

    func itemWith(id: Int64) -> ChatItem? {
        sectionsRelay.value.flatMap(\.elements).first(where: { $0.identity == id })
    }

    func getName(from senderId: Data) -> String {
        senderId == session.myId ? "You" : contact.nickname ?? contact.username
    }

    func itemAt(indexPath: IndexPath) -> ChatItem? {
        guard sectionsRelay.value.count > indexPath.section else { return nil }

        let items = sectionsRelay.value[indexPath.section].elements
        return items.count > indexPath.row ? items[indexPath.row] : nil
    }

    func section(at index: Int) -> ChatSection? {
        sectionsRelay.value.count > 0 ? sectionsRelay.value[index].model : nil
    }
}
