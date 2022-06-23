import HUD
import UIKit
import Models
import Shared
import Combine
import XXModels
import DependencyInjection

public final class CreateGroupController: UIViewController {
    @Dependency private var hud: HUDType
    @Dependency private var coordinator: ContactListCoordinating

    lazy private var titleLabel = UILabel()
    lazy private var createButton = UIButton()
    lazy private var screenView = CreateGroupView()

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
            attString.addAttribute(name: .foregroundColor, value: Asset.neutralDisabled.color, betweenCharacters: "#")

            titleLabel.attributedText = attString
        }
    }

    public override func loadView() {
        view = screenView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableAndCollection()
        setupBindings()
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = " "

        let back = UIButton.back()
        back.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [back, titleLabel])
        )

        createButton.setTitle(Localized.CreateGroup.create, for: .normal)
        createButton.setTitleColor(Asset.brandPrimary.color, for: .normal)
        createButton.titleLabel?.font = Fonts.Mulish.semiBold.font(size: 16.0)
        createButton.setTitleColor(Asset.neutralDisabled.color, for: .disabled)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: createButton)
    }

    private func setupTableAndCollection() {
        screenView.tableView.rowHeight = 64.0
        screenView.tableView.register(SmallAvatarAndTitleCell.self)
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
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath, ofType: SmallAvatarAndTitleCell.self)
            let title = (contact.nickname ?? contact.username) ?? ""
            cell.titleLabel.text = title
            cell.avatarView.setupProfile(title: title, image: contact.photo, size: .medium)

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
        viewModel.hud
            .receive(on: DispatchQueue.main)
            .sink { [hud] in hud.update(with: $0) }
            .store(in: &cancellables)

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

        viewModel.contacts
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

        screenView.searchComponent.textPublisher
            .removeDuplicates()
            .sink { [unowned self] in viewModel.filter($0) }
            .store(in: &cancellables)

        viewModel.info
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toGroupChat(with: $0, from: self) }
            .store(in: &cancellables)

        createButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                coordinator.toGroupDrawer(
                    with: count + 1,
                    from: self, { (name, welcome) in
                        viewModel.create(name: name, welcome: welcome, members: selectedElements)
                    }
                )
            }.store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
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
