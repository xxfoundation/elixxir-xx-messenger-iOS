import HUD
import UIKit
import Models
import Shared
import Combine
import XXLogger
import XXModels
import Foundation
import Integration
import Defaults
import Permissions
import ToastFeature
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

final class SingleChatViewModel: NSObject {
    @Dependency private var logger: XXLogger
    @Dependency private var session: SessionType
    @Dependency private var permissions: PermissionHandling
    @Dependency private var toastController: ToastController

    @KeyObject(.username, defaultValue: nil) var username: String?

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
        super.init()

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

extension SingleChatViewModel {
    struct Report: Encodable {
        struct ReportUser: Encodable {
            var userId: String
            var username: String
        }

        var sender: ReportUser
        var recipient: ReportUser
        var type: String
        var screenshot: String
    }

    private func blockContact() {
        var contact = contact
        contact.isBlocked = true
        _ = try? session.dbManager.saveContact(contact)
    }

    private func makeReportRequest(with screenshot: UIImage) -> URLRequest {
        let url = URL(string: "https://3.74.237.181:11420/report")

        let report = Report(
            sender: .init(
                userId: contact.id.base64EncodedString(),
                username: contact.username!
            ),
            recipient: .init(
                userId: session.myId.base64EncodedString(),
                username: username!
            ), type: "dm",
            screenshot: screenshot.jpegData(compressionQuality: 0.1)!.base64EncodedString())

        var request = try! URLRequest(url: url!, method: .post)
        request.httpBody = try! JSONEncoder().encode(report)
        return request
    }

    private func enqueueBlockedToast() {
        let name = (contact.nickname ?? contact.username) ?? ""
        toastController.enqueueToast(model: .init(
            title: "Your report has been sent and \(name) is now blocked.",
            leftImage: Asset.requestSentToaster.image
        ))
    }

    private func uploadReport(
        _ request: URLRequest,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            .dataTask(with: request) { data, response, error in
            if let error = error as? NSError {
                completion(.failure(error))
                return
            }

            if let data = data {
                completion(.success(()))
            }
        }.resume()
    }

    func proceeedWithReport(screenshot: UIImage, completion: @escaping () -> Void) {
        hudRelay.send(.on)

        uploadReport(makeReportRequest(with: screenshot)) { [weak self] in
            guard let self = self else { return }

            switch $0 {
            case .success:
                DispatchQueue.main.async {
                    self.blockContact()
                    self.enqueueBlockedToast()
                    self.hudRelay.send(.none)
                    completion()
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.hudRelay.send(.error(.init(with: error)))
                    completion()
                }
            }
        }
    }
}

extension SingleChatViewModel: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let serverTrust = challenge.protectionSpace.serverTrust
        let certificate = SecTrustGetCertificateAtIndex(serverTrust!, 0)

        let policies = NSMutableArray()
        policies.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        SecTrustSetPolicies(serverTrust!, policies)

        let remoteCertificateData: NSData = SecCertificateCopyData(certificate!)
        let pathToCert = Bundle.module.path(forResource: "report_cert", ofType: "crt")
        let localCertificate: NSData = NSData(contentsOfFile: pathToCert!)!

        if (remoteCertificateData.isEqual(to: localCertificate as Data)) {
            let credential: URLCredential = URLCredential(trust: serverTrust!)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
