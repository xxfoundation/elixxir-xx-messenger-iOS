import UIKit
import Shared
import Models
import Combine
import XXModels

final class ContactListTableController: UITableViewController {
    private var collation = UILocalizedIndexedCollation.current()
    private var sections: [[Contact]] = [] {
        didSet { self.tableView.reloadData() }
    }

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

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(SmallAvatarAndTitleCell.self)
        tableView.backgroundColor = Asset.neutralWhite.color
        tableView.sectionIndexColor = Asset.neutralDark.color
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)

        viewModel.contacts
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                let results = IndexedListCollator().sectioned(items: $0)
                self.collation = results.collation
                self.sections = results.sections
            }.store(in: &cancellables)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SmallAvatarAndTitleCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let contact = sections[indexPath.section][indexPath.row]
        cell.titleLabel.text = contact.nickname ?? contact.username
        cell.avatarView.setupProfile(title: contact.nickname ?? contact.username, image: contact.photo, size: .medium)
        return cell
    }

    override func numberOfSections(in: UITableView) -> Int {
        sections.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].count
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapRelay.send(sections[indexPath.section][indexPath.row])
    }

    override func sectionIndexTitles(for: UITableView) -> [String]? {
        collation.sectionIndexTitles
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        collation.sectionTitles[section]
    }

    override func tableView(_: UITableView, sectionForSectionIndexTitle: String, at index: Int) -> Int {
        collation.section(forSectionIndexTitle: index)
    }

    override func tableView(_: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        64
    }
}
