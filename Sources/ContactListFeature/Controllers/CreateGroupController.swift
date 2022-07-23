import HUD
import UIKit
import Models
import Shared
import Combine
import XXModels
import DependencyInjection

public final class CreateGroupController: UIViewController {
    @Dependency private var hud: HUD
    @Dependency private var coordinator: ContactListCoordinating

    lazy private var titleLabel = UILabel()
    lazy private var createButton = UIButton()
    lazy private var screenView = CreateGroupView()

    private var selectedElements = [Contact]() {
        didSet { screenView.bottomCollectionView.reloadData() }
    }
    private let viewModel = CreateGroupViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var topCollectionDataSource: UICollectionViewDiffableDataSource<SectionId, Contact>!
    private var bottomCollectionDataSource: UICollectionViewDiffableDataSource<SectionId, Contact>!

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
        setupCollectionViews()
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

    private func setupCollectionViews() {
        screenView.bottomCollectionView.register(AvatarCell.self)
        screenView.topCollectionView.register(CreateGroupCollectionCell.self)

        topCollectionDataSource = UICollectionViewDiffableDataSource<SectionId, Contact>(
            collectionView: screenView.topCollectionView
        ) { [weak viewModel] collectionView, indexPath, contact in
            let cell: CreateGroupCollectionCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

            let title = (contact.nickname ?? contact.username) ?? ""
            cell.setup(title: title, image: contact.photo)
            cell.didTapRemove = { viewModel?.didSelect(contact: contact) }

            return cell
        }

        bottomCollectionDataSource = UICollectionViewDiffableDataSource<SectionId, Contact>(
            collectionView: screenView.bottomCollectionView
        ) { [weak self] collectionView, indexPath, contact in
            let cell: AvatarCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            let title = (contact.nickname ?? contact.username) ?? ""

            cell.set(image: contact.photo, h1Text: title)

            if let selectedElements = self?.selectedElements, selectedElements.contains(contact) {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            } else {
                collectionView.deselectItem(at: indexPath, animated: true)
            }

            return cell
        }

        screenView.bottomCollectionView.delegate = self
        screenView.topCollectionView.dataSource = topCollectionDataSource
        screenView.bottomCollectionView.tintColor = Asset.brandPrimary.color
        screenView.bottomCollectionView.dataSource = bottomCollectionDataSource
        screenView.bottomCollectionView.allowsMultipleSelectionDuringEditing = true
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
                screenView.topCollectionView.isHidden = $0.count < 1

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
        .sink { [unowned self] in topCollectionDataSource.apply($0) }
        .store(in: &cancellables)

        viewModel.contacts
            .map { contacts -> NSDiffableDataSourceSnapshot<SectionId, Contact> in
                var snapshot = NSDiffableDataSourceSnapshot<SectionId, Contact>()
                let sections = [SectionId()]
                snapshot.appendSections(sections)
                sections.forEach { section in snapshot.appendItems(contacts, toSection: section) }
                return snapshot
            }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                let animating = bottomCollectionDataSource.snapshot().numberOfItems > 0
                bottomCollectionDataSource.apply($0, animatingDifferences: animating)
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
                        self.viewModel.create(name: name, welcome: welcome, members: self.selectedElements)
                    }
                )
            }.store(in: &cancellables)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension CreateGroupController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let contact = bottomCollectionDataSource.itemIdentifier(for: indexPath) {
            viewModel.didSelect(contact: contact)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let contact = bottomCollectionDataSource.itemIdentifier(for: indexPath) {
            viewModel.didSelect(contact: contact)
        }
    }
}
