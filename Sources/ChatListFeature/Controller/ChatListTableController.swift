import UIKit
import Shared
import Models
import Combine
import DifferenceKit
import DrawerFeature
import DependencyInjection

final class ChatListTableController: UITableViewController {
    @Dependency private var coordinator: ChatListCoordinating

    private var rows = [Chat]()
    private let viewModel: ChatListViewModel
    private let cellHeight: CGFloat = 83.0
    private var cancellables = Set<AnyCancellable>()
    private var drawerCancellables = Set<AnyCancellable>()

    init(_ viewModel: ChatListViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.register(ChatListCell.self)
        tableView.tableFooterView = UIView()

        viewModel
            .chatsPublisher
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
}

extension ChatListTableController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection: Int
    ) -> Int {
        return rows.count
    }

    override func tableView(
        _ tableView: UITableView,
        heightForRowAt: IndexPath
    ) -> CGFloat {
        return cellHeight
    }

    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let delete = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, complete in
            guard let self = self else { return }
            self.didRequestDeletionOf(self.rows[indexPath.row])
            complete(true)
        }

        delete.image = Asset.chatListDeleteSwipe.image
        delete.backgroundColor = Asset.accentDanger.color
        return UISwipeActionsConfiguration(actions: [delete])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch rows[indexPath.row] {
        case .contact(let info):
            guard info.contact.status == .friend else { return }
            coordinator.toSingleChat(with: info.contact, from: self)
        case .group(let info):
            coordinator.toGroupChat(with: info, from: self)
        }
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, ofType: ChatListCell.self)

        if case .contact(let info) = rows[indexPath.row] {
            cell.setupContact(
                name: info.contact.nickname ?? info.contact.username,
                image: info.contact.photo,
                date: Date.fromTimestamp(info.lastMessage!.timestamp),
                hasUnread: info.lastMessage!.unread,
                preview: info.lastMessage!.payload.text
            )
        }

        if case .group(let info) = rows[indexPath.row] {
            let date: Date = {
                guard let lastMessage = info.lastMessage else {
                    return info.group.createdAt
                }

                return Date.fromTimestamp(lastMessage.timestamp)
            }()

            let hasUnread: Bool = {
                guard let lastMessage = info.lastMessage else {
                    return false
                }

                return lastMessage.unread
            }()

            cell.setupGroup(
                name: info.group.name,
                date: date,
                preview: info.lastMessage?.payload.text,
                hasUnread: hasUnread
            )
        }

        return cell
    }

    private func didRequestDeletionOf(_ item: Chat) {
        let title: String
        let subtitle: String
        let actionTitle: String
        let actionClosure: () -> Void

        switch item {
        case .group(let info):
            title = Localized.ChatList.DeleteGroup.title
            subtitle = Localized.ChatList.DeleteGroup.subtitle
            actionTitle = Localized.ChatList.DeleteGroup.action
            actionClosure = { [weak viewModel] in viewModel?.leave(info.group) }

        case .contact(let info):
            title = Localized.ChatList.Delete.title
            subtitle = Localized.ChatList.Delete.subtitle
            actionTitle = Localized.ChatList.Delete.delete
            actionClosure = { [weak viewModel] in viewModel?.clear(info.contact) }
        }

        let actionButton = DrawerCapsuleButton(model: .init(title: actionTitle, style: .red))

        let drawer = DrawerController(with: [
            DrawerText(
                font: Fonts.Mulish.bold.font(size: 26.0),
                text: title,
                color: Asset.neutralActive.color,
                alignment: .left,
                spacingAfter: 19
            ),
            DrawerText(
                font: Fonts.Mulish.regular.font(size: 16.0),
                text: subtitle,
                color: Asset.neutralBody.color,
                alignment: .left,
                lineHeightMultiple: 1.1,
                spacingAfter: 39
            ),
            actionButton
        ])

        actionButton.action.receive(on: DispatchQueue.main)
            .sink {
                drawer.dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    self.drawerCancellables.removeAll()
                    actionClosure()
                }
            }.store(in: &drawerCancellables)

        coordinator.toDrawer(drawer, from: self)
    }
}
