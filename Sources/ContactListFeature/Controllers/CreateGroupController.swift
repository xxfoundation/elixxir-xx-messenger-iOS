import UIKit
import Shared
import Combine
import XXModels
import XXNavigation
import DI

public final class CreateGroupController: UIViewController {
  @Dependency var navigator: Navigator

  private lazy var titleLabel = UILabel()
  private lazy var createButton = UIButton()
  private lazy var screenView = CreateGroupView()

  private var selectedElements = [Contact]() {
    didSet { screenView.tableView.reloadData() }
  }
  private let viewModel = CreateGroupViewModel()
  private var cancellables = Set<AnyCancellable>()
  private var tableDataSource: UITableViewDiffableDataSource<SectionId, Contact>!
  private var collectionDataSource: UICollectionViewDiffableDataSource<SectionId, Contact>!

  private var count = 0 {
    didSet {
      createButton.isEnabled = count >= 2 && count <= 10

      let text = Localized.CreateGroup.title("\(count)")
      let attString = NSMutableAttributedString(string: text)
      attString.addAttribute(.font, value: Fonts.Mulish.semiBold.font(size: 18.0) as Any)
      attString.addAttribute(.foregroundColor, value: Asset.neutralActive.color)
      attString.addAttributes(attributes: [
        .foregroundColor: Asset.neutralDisabled.color,
        .font: Fonts.Mulish.regular.font(size: 14.0) as Any
      ], betweenCharacters: "#")

      titleLabel.attributedText = attString
      titleLabel.sizeToFit()
    }
  }

  public override func loadView() {
    view = screenView
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = ""
    navigationController?.navigationBar
      .customize(backgroundColor: Asset.neutralWhite.color)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupTableAndCollection()
    setupBindings()

    count = 0
  }

  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    navigationItem.leftItemsSupplementBackButton = true

    createButton.setTitle(Localized.CreateGroup.create, for: .normal)
    createButton.setTitleColor(Asset.brandPrimary.color, for: .normal)
    createButton.titleLabel?.font = Fonts.Mulish.semiBold.font(size: 16.0)
    createButton.setTitleColor(Asset.neutralDisabled.color, for: .disabled)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: createButton)
  }

  private func setupTableAndCollection() {
    screenView.tableView.rowHeight = 64.0
    screenView.tableView.register(AvatarCell.self)
    screenView.collectionView.register(CreateGroupCollectionCell.self)

    collectionDataSource = UICollectionViewDiffableDataSource<SectionId, Contact>(
      collectionView: screenView.collectionView
    ) { [weak viewModel] collectionView, indexPath, contact in
      let cell: CreateGroupCollectionCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

      let title = (contact.nickname ?? contact.username) ?? ""
      cell.setup(title: title, image: contact.photo)
      cell.didTapRemove = { viewModel?.didSelect(contact: contact) }

      return cell
    }

    tableDataSource = DiffEditableDataSource<SectionId, Contact>(
      tableView: screenView.tableView
    ) { [weak self] tableView, indexPath, contact in
      let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, ofType: AvatarCell.self)
      let title = (contact.nickname ?? contact.username) ?? ""

      cell.setup(title: title, image: contact.photo)

      if let selectedElements = self?.selectedElements, selectedElements.contains(contact) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
      } else {
        tableView.deselectRow(at: indexPath, animated: true)
      }

      return cell
    }

    screenView.tableView.delegate = self
    screenView.tableView.dataSource = tableDataSource
    screenView.collectionView.dataSource = collectionDataSource
  }

  private func setupBindings() {
    let selected = viewModel.selected.share()

    selected
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.collectionView.isHidden = $0.count < 1

        count = $0.count
        selectedElements = $0
      }.store(in: &cancellables)

    selected.map { selectedContacts in
      var snapshot = NSDiffableDataSourceSnapshot<SectionId, Contact>()
      let sections = [SectionId()]
      snapshot.appendSections(sections)
      sections.forEach { section in snapshot.appendItems(selectedContacts, toSection: section) }
      return snapshot
    }
    .receive(on: DispatchQueue.main)
    .sink { [unowned self] in collectionDataSource.apply($0) }
    .store(in: &cancellables)

    viewModel
      .contacts
      .map { contacts in
        var snapshot = NSDiffableDataSourceSnapshot<SectionId, Contact>()
        let sections = [SectionId()]
        snapshot.appendSections(sections)
        sections.forEach { section in snapshot.appendItems(contacts, toSection: section) }
        return snapshot
      }
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        tableDataSource.apply($0, animatingDifferences: tableDataSource.snapshot().numberOfItems > 0)
      }.store(in: &cancellables)

    screenView
      .searchComponent
      .textPublisher
      .removeDuplicates()
      .sink { [unowned self] in
        viewModel.filter($0)
      }.store(in: &cancellables)

    viewModel
      .info
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentGroupChat(model: $0))
      }.store(in: &cancellables)

    createButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
//        coordinator.toGroupDrawer(
//          with: count,
//          from: self, { (name, welcome) in
//            self.viewModel.create(
//              name: name,
//              welcome: welcome,
//              members: self.selectedElements
//            )
//          }
//        )
      }.store(in: &cancellables)
  }
}

extension CreateGroupController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let contact = tableDataSource.itemIdentifier(for: indexPath) {
      viewModel.didSelect(contact: contact)
    }
  }

  public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    if let contact = tableDataSource.itemIdentifier(for: indexPath) {
      viewModel.didSelect(contact: contact)
    }
  }
}
