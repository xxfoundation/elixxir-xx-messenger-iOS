import UIKit
import Theme
import Shared
import Combine
import DependencyInjection

public final class ContactListController: UIViewController {
    @Dependency private var coordinator: ContactListCoordinating
    @Dependency private var statusBarController: StatusBarStyleControlling

    lazy private var screenView = ContactListView()
    lazy private var tableController = ContactListTableController(viewModel)

    private let viewModel = ContactListViewModel()
    private var cancellables = Set<AnyCancellable>()

    public override func loadView() {
        view = screenView
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarController.style.send(.darkContent)
        navigationController?.navigationBar.customize(backgroundColor: Asset.neutralWhite.color)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupBindings()
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

        let search = UIButton()
        search.tintColor = Asset.neutralActive.color
        search.setImage(Asset.contactListSearch.image, for: .normal)
        search.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
        search.accessibilityIdentifier = Localized.Accessibility.ContactList.search

        let scanButton = UIButton()
        scanButton.setImage(Asset.sharedScan.image, for: .normal)
        scanButton.addTarget(self, action: #selector(didTapScan), for: .touchUpInside)

        let rightStack = UIStackView()
        rightStack.spacing = 15
        rightStack.addArrangedSubview(scanButton)
        rightStack.addArrangedSubview(search)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightStack)

        search.snp.makeConstraints { $0.width.equalTo(40) }
    }

    private func setupTableView() {
        addChild(tableController)
        screenView.addSubview(tableController.view)

        tableController.view.snp.makeConstraints { make in
            make.top.equalTo(screenView.topStackView.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }

        tableController.didMove(toParent: self)
    }

    private func setupBindings() {
        tableController.didTap
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toSingleChat(with: $0, from: self) }
            .store(in: &cancellables)

        screenView.requestsButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toRequests(from: self) }
            .store(in: &cancellables)

        screenView.newGroupButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toNewGroup(from: self) }
            .store(in: &cancellables)

        screenView.searchButton
            .publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in coordinator.toSearch(from: self) }
            .store(in: &cancellables)

        viewModel.requestCount
            .receive(on: DispatchQueue.main)
            .sink { [weak screenView] in screenView?.requestsButton.updateNotification($0) }
            .store(in: &cancellables)

        viewModel.contacts
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                screenView.stackView.isHidden = !$0.isEmpty

                if $0.isEmpty {
                    screenView.bringSubviewToFront(screenView.stackView)
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
