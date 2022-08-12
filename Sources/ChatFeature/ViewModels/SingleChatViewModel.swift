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
    private let replySubject = PassthroughSubject<(String, String), Never>()
    private let navigationRoutes = PassthroughSubject<SingleChatNavigationRoutes, Never>()
    private let sectionsRelay = CurrentValueSubject<[ArraySection<ChatSection, Message>], Never>([])
    private let reportPopupSubject = PassthroughSubject<Void, Never>()

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var isOnline: AnyPublisher<Bool, Never> { session.isOnline }
    var contactPublisher: AnyPublisher<Contact, Never> { contactSubject.eraseToAnyPublisher() }
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

    private func updateRecentState(_ contact: Contact) {
        if contact.isRecent == true {
            var contact = contact
            contact.isRecent = false
            _ = try? session.dbManager.saveContact(contact)
        }
    }

    func viewDidAppear() {
        updateRecentState(contact)
    }

    init(_ contact: Contact) {
        self.contactSubject = .init(contact)

        updateRecentState(contact)

        session.dbManager.fetchContactsPublisher(Contact.Query(id: [contact.id]))
            .assertNoFailure()
            .compactMap { $0.first }
            .sink { [unowned self] in contactSubject.send($0) }
            .store(in: &cancellables)

        session.dbManager.fetchMessagesPublisher(.init(chat: .direct(session.myId, contact.id)))
            .assertNoFailure()
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
    }

    // MARK: Public

    func getFileTransferWith(id: Data) -> FileTransfer {
        guard let transfer = try? session.dbManager.fetchFileTransfers(.init(id: [id])).first else {
            fatalError()
        }

        return transfer
    }

    func didSendAudio(url: URL) {
        session.sendFile(url: url, to: contact)
    }

    func didSend(image: UIImage) {
        guard let imageData = image.orientedUp().jpegData(compressionQuality: 1.0) else { return }
        hudRelay.send(.on)

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
        let assignment = Message.Assignments(isUnread: false)
        let query = Message.Query(chat: .direct(session.myId, contact.id))
        _ = try? session.dbManager.bulkUpdateMessages(query, assignment)
    }

    func didRequestDeleteAll() {
        _ = try? session.dbManager.deleteMessages(.init(chat: .direct(session.myId, contact.id)))
    }

    func didRequestRetry(_ message: Message) {
        guard let id = message.id else { return }
        session.retryMessage(id)
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
        let text = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let payload = Payload(text: text, reply: stagedReply)
        session.send(payload, toContact: contact)
        stagedReply = nil
    }

    func didRequestReply(_ message: Message) {
        guard let networkId = message.networkId else { return }

        let senderTitle: String = {
            if message.senderId == session.myId {
                return "You"
            } else {
                return (contact.nickname ?? contact.username) ?? "Fetching username..."
            }
        }()

        replySubject.send((senderTitle, message.text))
        stagedReply = Reply(messageId: networkId, senderId: message.senderId)
    }

    func getReplyContent(for messageId: Data) -> (String, String) {
        guard let message = try? session.dbManager.fetchMessages(.init(networkId: messageId)).first else {
            return ("[DELETED]", "[DELETED]")
        }

        guard let contact = try? session.dbManager.fetchContacts(.init(id: [message.senderId])).first else {
            fatalError()
        }

        let contactTitle = (contact.nickname ?? contact.username) ?? "You"
        return (contactTitle, message.text)
    }

    func uploadReport(screenshot: UIImage) {
        UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)

        var contact = contact
        contact.isBlocked = true
        _ = try? session.dbManager.saveContact(contact)
    }

    func showRoundFrom(_ roundURL: String?) {
        if let urlString = roundURL, !urlString.isEmpty {
            navigationRoutes.send(.webview(urlString))
        } else {
            navigationRoutes.send(.waitingRound)
        }
    }

    func didRequestDelete(_ items: [Message]) {
        _ = try? session.dbManager.deleteMessages(.init(id: Set(items.compactMap(\.id))))
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
}
