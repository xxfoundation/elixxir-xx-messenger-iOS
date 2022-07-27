import UIKit
import Theme
import Shared
import Combine
import XXModels
import CollectionView
import DependencyInjection

public final class ContactListController: UIViewController {
    @Dependency var coordinator: ContactListCoordinating
    @Dependency var statusBarController: StatusBarStyleControlling

    lazy private var screenView = ContactListView()

    private var dataSource: IndexedContactList!
    private let viewModel = ContactListViewModel()
    private var cancellables = Set<AnyCancellable>()

    public override func loadView() {
        view = screenView
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.darkContent)
        navigationController?.navigationBar.customize(
            backgroundColor: Asset.neutralWhite.color
        )
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        setupBindings()
    }

    private func setupCollectionView() {
        screenView.collectionView.delegate = self
        screenView.collectionView.dataSource = dataSource
        screenView.collectionView.tintColor = Asset.neutralDark.color

        CellFactory.avatarCellFactory()
            .register(in: screenView.collectionView)

        dataSource = IndexedContactList(
            collectionView: screenView.collectionView
        ) { collectionView, indexPath, contact in
            CellFactory.avatarCellFactory().build(for: contact, in: collectionView, at: indexPath)
        }
    }

    private func setupNavigationBar() {
        navigationItem.backButtonTitle = " "

        let titleLabel = UILabel()
        titleLabel.text = Localized.ContactList.title
        titleLabel.textColor = Asset.neutralActive.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 18.0)

        let menuButton = UIButton()
        menuButton.tintColor = Asset.neutralDark.color
        menuButton.setImage(Asset.chatListMenu.image, for: .normal)
        menuButton.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
        menuButton.snp.makeConstraints { $0.width.equalTo(50) }

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: UIStackView(arrangedSubviews: [menuButton, titleLabel])
        )

        let searchButton = UIButton()
        searchButton.tintColor = Asset.neutralActive.color
        searchButton.setImage(Asset.contactListSearch.image, for: .normal)
        searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
        searchButton.accessibilityIdentifier = Localized.Accessibility.ContactList.search

        let scanButton = UIButton()
        scanButton.setImage(Asset.sharedScan.image, for: .normal)
        scanButton.addTarget(self, action: #selector(didTapScan), for: .touchUpInside)

        let rightStack = UIStackView()
        rightStack.spacing = 15
        rightStack.addArrangedSubview(scanButton)
        rightStack.addArrangedSubview(searchButton)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightStack)

        searchButton.snp.makeConstraints {
            $0.width.equalTo(40)
        }
    }

    private func setupBindings() {
        screenView.requestsButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                coordinator.toRequests(from: self)
            }.store(in: &cancellables)

        screenView.newGroupButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                coordinator.toNewGroup(from: self)
            }.store(in: &cancellables)

        screenView.emptyView.searchButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                coordinator.toSearch(from: self)
            }.store(in: &cancellables)

        viewModel.requestCount
            .receive(on: DispatchQueue.main)
            .sink { [weak screenView] in
                screenView?.requestsButton.updateNotification($0)
            }.store(in: &cancellables)

        viewModel.snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] snapshot in
                screenView.emptyView.isHidden = snapshot.numberOfItems > 0

                if snapshot.numberOfItems == 0 {
                    screenView.bringSubviewToFront(screenView.emptyView)
                }

                let animatingDifferences = dataSource.snapshot().numberOfItems > 0
                dataSource.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] in
                    guard let self = self else { return }

                    self.dataSource.set(indexTitles: snapshot.itemIdentifiers.map { contact -> String in
                        let name = (contact.nickname ?? contact.username) ?? ""
                        return "\(name.first!)"
                    })

                    self.screenView.collectionView.reloadData()
                }

            }.store(in: &cancellables)
    }

    @objc private func didTapSearch() {
        coordinator.toSearch(from: self)
    }

    @objc private func didTapScan() {
        coordinator.toScan(from: self)
    }

    @objc private func didTapMenu() {
        coordinator.toSideMenu(from: self)
    }
}

extension ContactListController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let contact = dataSource.itemIdentifier(for: indexPath) {
            coordinator.toSingleChat(with: contact, from: self)
        }
    }
}
