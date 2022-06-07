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
            case .chat(let subitem):
                if case .contact(let info) = subitem {
                    cell.setupContact(
                        name: info.contact.nickname ?? info.contact.username,
                        image: info.contact.photo,
                        date: Date.fromTimestamp(info.lastMessage!.timestamp),
                        hasUnread: info.lastMessage!.unread,
                        preview: info.lastMessage!.payload.text
                    )
                }

                if case .group(let info) = subitem {
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

            case .connection(let contact):
                cell.setupContact(
                    name: contact.nickname ?? contact.username,
                    image: contact.photo,
                    date: nil,
                    hasUnread: false,
                    preview: contact.username
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
            case .chat(let chat):
                switch chat {
                case .contact(let info):
                    guard info.contact.status == .friend else { return }
                    coordinator.toSingleChat(with: info.contact, from: self)
                case .group(let info):
                    coordinator.toGroupChat(with: info, from: self)
                }
            case .connection(let contact):
                coordinator.toContact(contact, from: self)
            }
        }
    }
}
