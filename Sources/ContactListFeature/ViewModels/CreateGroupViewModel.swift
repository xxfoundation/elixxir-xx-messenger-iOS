import HUD
import UIKit
import Models
import Combine
import XXModels
import Defaults
import XXClient
import ReportingFeature
import CombineSchedulers
import DependencyInjection

final class CreateGroupViewModel {
    @KeyObject(.username, defaultValue: "") var username: String

    // MARK: Injected

    @Dependency var database: Database
    @Dependency var groupManager: GroupChat
    @Dependency var userDiscovery: UserDiscovery
    @Dependency var reportingStatus: ReportingStatus

    // MARK: Properties

    var myId: Data {
        try! GetIdFromContact.live(userDiscovery.getContact())
    }

    var selected: AnyPublisher<[Contact], Never> {
        selectedContactsRelay.eraseToAnyPublisher()
    }

    var contacts: AnyPublisher<[Contact], Never> {
        contactsRelay.eraseToAnyPublisher()
    }

    var hud: AnyPublisher<HUDStatus, Never> {
        hudRelay.eraseToAnyPublisher()
    }

    var info: AnyPublisher<GroupInfo, Never> {
        infoRelay.eraseToAnyPublisher()
    }

    var backgroundScheduler: AnySchedulerOf<DispatchQueue>
    = DispatchQueue.global().eraseToAnyScheduler()

    private var allContacts = [Contact]()
    private var cancellables = Set<AnyCancellable>()
    private let infoRelay = PassthroughSubject<GroupInfo, Never>()
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)
    private let contactsRelay = CurrentValueSubject<[Contact], Never>([])
    private let selectedContactsRelay = CurrentValueSubject<[Contact], Never>([])

    // MARK: Lifecycle

    init() {
        let query = Contact.Query(
            authStatus: [.friend],
            isBlocked: reportingStatus.isEnabled() ? false : nil,
            isBanned: reportingStatus.isEnabled() ? false : nil
        )

        database.fetchContactsPublisher(query)
            .assertNoFailure()
            .map { $0.filter { $0.id != self.myId }}
            .map { $0.sorted(by: { $0.username! < $1.username! })}
            .sink { [unowned self] in
                allContacts = $0
                contactsRelay.send($0)
            }.store(in: &cancellables)
    }

    // MARK: Public

    func didSelect(contact: Contact) {
        if selectedContactsRelay.value.contains(contact) {
            selectedContactsRelay.value.removeAll { $0.username == contact.username }
        } else {
            selectedContactsRelay.value.append(contact)
        }
    }

    func filter(_ text: String) {
        guard text.isEmpty == false else {
            contactsRelay.send(allContacts)
            return
        }

        contactsRelay.send(
            allContacts.filter {
                ($0.username ?? "").contains(text.lowercased())
            }
        )
    }

    func create(name: String, welcome: String?, members: [Contact]) {
        hudRelay.send(.on)

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                let report = try self.groupManager.makeGroup(
                    membership: members.map(\.id),
                    message: welcome?.data(using: .utf8),
                    name: name.data(using: .utf8)
                )

                let group = Group(
                    id: report.id,
                    name: name,
                    leaderId: self.myId,
                    createdAt: Date(),
                    authStatus: .participating,
                    serialized: try report.encode() // ?
                )

                _ = try self.database.saveGroup(group)

                if let welcomeMessage = welcome {
                    try self.database.saveMessage(
                        Message(
                            senderId: self.myId,
                            recipientId: nil,
                            groupId: group.id,
                            date: group.createdAt,
                            status: .sent,
                            isUnread: false,
                            text: welcomeMessage,
                            replyMessageId: nil,
                            roundURL: nil,
                            fileTransferId: nil
                        )
                    )
                }

                try members
                    .map { GroupMember(groupId: group.id, contactId: $0.id) }
                    .forEach { try self.database.saveGroupMember($0) }

                let query = GroupInfo.Query(groupId: group.id)
                let info = try self.database.fetchGroupInfos(query).first

                self.infoRelay.send(info!)
                self.hudRelay.send(.none)
            } catch {
                self.hudRelay.send(.error(.init(with: error)))
            }
        }
    }
}
