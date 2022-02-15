import UIKit
import Shared
import Combine
import Models
import DifferenceKit
import DependencyInjection

final class ChatListTableController: UITableViewController {
    // MARK: Injected

    @Dependency private var coordinator: ChatListCoordinating

    // MARK: Published

    @Published var numberOfSelectedRows = 0

    // MARK: Properties

    var longPressPublisher: AnyPublisher<Void, Never> {
        longPressRelay.eraseToAnyPublisher()
    }

    var deletePublisher: AnyPublisher<IndexPath, Never> {
        deleteRelay.eraseToAnyPublisher()
    }

    private var rows = [GenericChatInfo]()
    private let viewModel: ChatListViewModelType
    private var cancellables = Set<AnyCancellable>()
    private let longPressRelay = PassthroughSubject<Void, Never>()
    private let deleteRelay = PassthroughSubject<IndexPath, Never>()

    // MARK: Lifecycle

    init(_ viewModel: ChatListViewModelType) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBindings()
    }

    // MARK: Private

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.register(ChatListCell.self)
        tableView.tintColor = Asset.brandPrimary.color
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.tableFooterView = UIView()
    }

    private func setupBindings() {
        viewModel
            .chatsRelay
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                guard !self.rows.isEmpty else {
                    self.rows = $0
                    tableView.reloadData()
                    return
                }

                self.tableView.reload(
                    using: StagedChangeset(source: self.rows, target: $0),
                    deleteSectionsAnimation: .automatic,
                    insertSectionsAnimation: .automatic,
                    reloadSectionsAnimation: .none,
                    deleteRowsAnimation: .automatic,
                    insertRowsAnimation: .automatic,
                    reloadRowsAnimation: .none
                ) { [unowned self] in
                    self.rows = $0
                }
            }.store(in: &cancellables)
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, ofType: ChatListCell.self)
        let chatInfo = rows[indexPath.row]

        var name: String!

        if let contact = chatInfo.contact {
            name = contact.nickname ?? contact.username
        } else {
            name = chatInfo.groupInfo!.group.name
        }

        cell.title.text = name
        cell.avatar.set(
            cornerRadius: 16,
            username: name,
            image: chatInfo.contact?.photo
        )

        cell.didLongPress = { [weak longPressRelay] in
            longPressRelay?.send()
        }

        if let latestGroupMessage = chatInfo.groupInfo?.lastMessage {
            cell.title.alpha = 1.0
            cell.avatar.alpha = 1.0
            cell.date = Date.fromTimestamp(latestGroupMessage.timestamp)
            cell.preview.text = latestGroupMessage.payload.text
            cell.unread.backgroundColor = latestGroupMessage.unread ? Asset.brandPrimary.color : .clear
        }

        if let latestE2EMessage = chatInfo.latestE2EMessage {
            cell.title.alpha = 1.0
            cell.avatar.alpha = 1.0
            cell.date = Date.fromTimestamp(latestE2EMessage.timestamp)
            cell.preview.text = latestE2EMessage.payload.text
            cell.unread.backgroundColor = latestE2EMessage.unread ? Asset.brandPrimary.color : .clear
        }

        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int { rows.count }

    // MARK: UITableViewDelegate

    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat { 72 }

    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let delete = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, complete in
            self?.deleteRelay.send(indexPath)
            complete(true)
        }

        delete.image = Asset.chatListDeleteSwipe.image
        delete.backgroundColor = Asset.accentDanger.color

        return UISwipeActionsConfiguration(actions: [delete])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            let genericChat = viewModel.chatsRelay.value[indexPath.row]

            guard let contact = genericChat.contact else {
                coordinator.toGroupChat(with: genericChat.groupInfo!, from: self)
                return
            }

            guard contact.status == .friend else { return }
            coordinator.toSingleChat(with: contact, from: self)
        } else {
            numberOfSelectedRows += 1
        }
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        numberOfSelectedRows -= 1
    }
}
