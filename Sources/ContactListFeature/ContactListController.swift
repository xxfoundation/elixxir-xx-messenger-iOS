import UIKit
import Shared
import Combine
import AppCore
import Dependencies
import AppResources
import AppNavigation

public final class ContactListController: UIViewController {
  @Dependency(\.navigator) var navigator: Navigator
  @Dependency(\.app.statusBar) var statusBar: StatusBarStylist

  private lazy var screenView = ContactListView()
  private lazy var tableController = ContactListTableController(viewModel)

  private let viewModel = ContactListViewModel()
  private var cancellables = Set<AnyCancellable>()

  public override func loadView() {
    view = screenView
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    statusBar.set(.darkContent)
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

    search.snp.makeConstraints {
      $0.width.equalTo(40)
    }
  }

  private func setupTableView() {
    addChild(tableController)
    screenView.addSubview(tableController.view)
    tableController.view.snp.makeConstraints {
      $0.top.equalTo(screenView.topStackView.snp.bottom)
      $0.left.bottom.right.equalToSuperview()
    }
    tableController.didMove(toParent: self)
  }

  private func setupBindings() {
    tableController
      .didTap
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentChat(
          contact: $0,
          on: navigationController!
        ))
      }.store(in: &cancellables)

    screenView
      .requestsButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentRequests(on: navigationController!))
      }.store(in: &cancellables)

    screenView
      .newGroupButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentGroupDraft(on: navigationController!))
      }.store(in: &cancellables)

    screenView
      .searchButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentSearch(
          searching: nil,
          replacing: false,
          on: navigationController!
        ))
      }.store(in: &cancellables)

    viewModel
      .requestCount
      .receive(on: DispatchQueue.main)
      .sink { [weak screenView] in
        screenView?.requestsButton.updateNotification($0)
      }.store(in: &cancellables)

    viewModel
      .contacts
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.stackView.isHidden = !$0.isEmpty
        if $0.isEmpty {
          screenView.bringSubviewToFront(screenView.stackView)
        }
      }.store(in: &cancellables)
  }

  @objc private func didTapSearch() {
    navigator.perform(PresentSearch(
      searching: nil,
      replacing: false,
      on: navigationController!
    ))
  }

  @objc private func didTapScan() {
    navigator.perform(PresentScan(on: navigationController!))
  }

  @objc private func didTapMenu() {
    navigator.perform(PresentMenu(currentItem: .contacts, from: self))
  }
}
