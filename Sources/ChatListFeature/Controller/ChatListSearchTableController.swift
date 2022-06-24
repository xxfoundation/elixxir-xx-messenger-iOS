import UIKit
import Shared
import Models
import Combine
import DependencyInjection

class ChatSearchListTableViewDiffableDataSource: UITableViewDiffableDataSource<SearchSection, SearchItem> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch snapshot().sectionIdentifiers[section] {
        case .chats:
            return "CHATS"
        case .connections:
            return "CONNECTIONS"
        }
    }
}

final class ChatSearchTableController: UITableViewController {
    @Dependency private var coordinator: ChatListCoordinating

    private let viewModel: ChatListViewModel
    private let cellHeight: CGFloat = 83.0
    private var cancellables = Set<AnyCancellable>()
    private var tableDataSource: ChatSearchListTableViewDiffableDataSource?

    init(_ viewModel: ChatListViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)

        tableDataSource = ChatSearchListTableViewDiffableDataSource(
            tableView: tableView
        ) { table, indexPath, item in
            let cell = table.dequeueReusableCell(forIndexPath: indexPath, ofType: ChatListCell.self)
            switch item {
            case .chat(let info):
                switch info {
                case .group(let group):
                    cell.setupGroup(
                        name: group.name,
                        date: group.createdAt,
                        preview: nil,
                        hasUnread: false
                    )

                case .groupChat(let groupChatInfo):
                    cell.setupGroup(
                        name: groupChatInfo.group.name,
                        date: groupChatInfo.lastMessage.date,
                        preview: groupChatInfo.lastMessage.text,
                        hasUnread: groupChatInfo.lastMessage.isUnread
                    )

                case .contactChat(let contactChatInfo):
                    cell.setupContact(
                        name: (contactChatInfo.contact.nickname ?? contactChatInfo.contact.username) ?? "",
                        image: contactChatInfo.contact.photo,
                        date: contactChatInfo.lastMessage.date,
                        hasUnread: contactChatInfo.lastMessage.isUnread,
                        preview: contactChatInfo.lastMessage.text
                    )
                }

            case .connection(let contact):
                cell.setupContact(
                    name: (contact.nickname ?? contact.username) ?? "",
                    image: contact.photo,
                    date: nil,
                    hasUnread: false,
                    preview: contact.username ?? ""
                )
            }

            return cell
        }
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.sectionIndexColor = .blue
        tableView.register(ChatListCell.self)
        tableView.dataSource = tableDataSource
        view.backgroundColor = Asset.neutralWhite.color

        viewModel.searchPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in tableDataSource?.apply($0, animatingDifferences: false) }
            .store(in: &cancellables)
    }
}

extension ChatSearchTableController {
    override func tableView(
        _ tableView: UITableView,
        heightForRowAt: IndexPath
    ) -> CGFloat {
        return cellHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = tableDataSource?.itemIdentifier(for: indexPath) {
            switch item {
            case .chat(let chatInfo):
                switch chatInfo {
                case .group(let group):
                    if let groupInfo = viewModel.groupInfo(from: group) {
                        coordinator.toGroupChat(with: groupInfo, from: self)
                    }

                case .groupChat(let info):
                    if let groupInfo = viewModel.groupInfo(from: info.group) {
                        coordinator.toGroupChat(with: groupInfo, from: self)
                    }

                case .contactChat(let info):
                    guard info.contact.authStatus == .friend else { return }
                    coordinator.toSingleChat(with: info.contact, from: self)
                }

            case .connection(let contact):
                coordinator.toContact(contact, from: self)
            }
        }
    }
}
