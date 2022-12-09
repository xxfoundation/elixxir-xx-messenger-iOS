import UIKit
import Shared
import Combine
import XXModels
import AppResources

final class ContactListTableController: UITableViewController {
  private final class Row: NSObject {
    init(contact: XXModels.Contact) {
      self.contact = contact
      self.title = contact.nickname ?? contact.username ?? ""
    }

    let contact: XXModels.Contact
    @objc let title: String
  }

  private struct Section {
    var title: String
    var rows: [Row]
  }

  private var collation = UILocalizedIndexedCollation.current()
  private var sections: [Section] = []

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
    tableView.register(AvatarCell.self)
    tableView.backgroundColor = Asset.neutralWhite.color
    tableView.sectionIndexColor = Asset.neutralDark.color
    tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)

    viewModel.contacts
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] contacts in
        sections = makeSections(from: contacts)
        tableView.reloadData()
      }.store(in: &cancellables)
  }

  private func makeSections(from contacts: [XXModels.Contact]) -> [Section] {
    let rows = contacts.map(Row.init(contact:))
    let selector: Selector = #selector(getter: Row.title)
    let sortedRows = collation.sortedArray(from: rows, collationStringSelector: selector) as! [Row]
    var sections = collation.sectionTitles.map { Section(title: $0, rows: []) }
    sortedRows.forEach { row in
      let sectionNumber = collation.section(for: row, collationStringSelector: selector)
      sections[sectionNumber].rows.append(row)
    }
    sections.removeAll(where: \.rows.isEmpty)
    return sections
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: AvatarCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
    let contact = sections[indexPath.section].rows[indexPath.row].contact
    let name = (contact.nickname ?? contact.username) ?? "Fetching username..."
    cell.setup(title: name, image: contact.photo)
    return cell
  }

  override func numberOfSections(in: UITableView) -> Int {
    sections.count
  }

  override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    sections[section].rows.count
  }

  override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    let contact = sections[indexPath.section].rows[indexPath.row].contact
    tapRelay.send(contact)
  }

  override func sectionIndexTitles(for: UITableView) -> [String]? {
    collation.sectionIndexTitles
  }

  override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
    sections[section].title
  }

  override func tableView(_: UITableView, sectionForSectionIndexTitle: String, at index: Int) -> Int {
    if let index = sections.lastIndex(where: { $0.title <= sectionForSectionIndexTitle }) {
      return index
    } else {
      return sections.index(before: sections.endIndex)
    }
  }

  override func tableView(_: UITableView, heightForRowAt: IndexPath) -> CGFloat {
    64
  }
}
