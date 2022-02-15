import UIKit
import Shared
import Combine
import Models
import DifferenceKit

final class ContactListTableController: UITableViewController {
    private var contacts = [Contact]()
    private let viewModel: ContactListViewModel
    private var cancellables = Set<AnyCancellable>()
    private let tapRelay = PassthroughSubject<Contact, Never>()

    var didTap: AnyPublisher<Contact, Never> { tapRelay.eraseToAnyPublisher() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    init(_ viewModel: ContactListViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) { nil }

    func filter(_ text: String) {
        viewModel.filter(text)
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(SmallAvatarAndTitleCell.self)
        tableView.backgroundColor = Asset.neutralWhite.color
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)

        viewModel
            .contacts
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                guard !self.contacts.isEmpty else {
                    self.contacts = $0
                    tableView.reloadData()
                    return
                }

                self.tableView.reload(
                    using: StagedChangeset(source: self.contacts, target: $0),
                    deleteSectionsAnimation: .none,
                    insertSectionsAnimation: .none,
                    reloadSectionsAnimation: .none,
                    deleteRowsAnimation: .none,
                    insertRowsAnimation: .none,
                    reloadRowsAnimation: .none
                ) { [unowned self] in
                    self.contacts = $0
                }
            }.store(in: &cancellables)
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SmallAvatarAndTitleCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.title.text = contacts[indexPath.row].nickname ?? contacts[indexPath.row].username

        cell.avatar.set(
            cornerRadius: 10,
            username: contacts[indexPath.row].nickname ?? contacts[indexPath.row].username,
            image: contacts[indexPath.row].photo
        )

        return cell
    }

    override func tableView(_: UITableView, numberOfRowsInSection: Int) -> Int { contacts.count }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapRelay.send(contacts[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
}
