import UIKit
import Shared
import Combine
import XXModels
import MenuFeature
import Navigation
import DI

public final class ChatListController: UIViewController {
  @Dependency var navigator: Navigator
  @Dependency var barStylist: StatusBarStylist
  
  private lazy var screenView = ChatListView()
  private lazy var topLeftView = ChatListTopLeftNavView()
  private lazy var topRightView = ChatListTopRightNavView()
  private lazy var tableController = ChatListTableController(viewModel)
  private lazy var searchTableController = ChatSearchTableController(viewModel)
  private var collectionDataSource: UICollectionViewDiffableDataSource<SectionId, Contact>!
  
  private let viewModel = ChatListViewModel()
  private var cancellables = Set<AnyCancellable>()
  private var drawerCancellables = Set<AnyCancellable>()
  
  private var isEditingSearch = false {
    didSet {
      screenView.listContainerView
        .showRecentsCollection(isEditingSearch ? false : shouldBeShowingRecents)
    }
  }
  
  private var shouldBeShowingRecents = false {
    didSet {
      screenView.listContainerView
        .showRecentsCollection(isEditingSearch ? false : shouldBeShowingRecents)
    }
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    navigationItem.backButtonTitle = ""
  }
  
  required init?(coder: NSCoder) { nil }
  
  public override func loadView() {
    view = screenView
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    barStylist.styleSubject.send(.darkContent)
    navigationController?.navigationBar.customize(backgroundColor: Asset.neutralWhite.color)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupChatList()
    setupBindings()
    setupNavigationBar()
    setupRecentContacts()
  }
  
  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: topLeftView)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: topRightView)
    
    topRightView
      .actionPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        switch $0 {
        case .didTapSearch:
          navigator.perform(PresentSearch(replacing: false))
        case .didTapNewGroup:
          navigator.perform(PresentNewGroup())
        }
      }.store(in: &cancellables)
    
    viewModel
      .badgeCountPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        topLeftView.updateBadge($0)
      }.store(in: &cancellables)
    
    topLeftView
      .actionPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentMenu(currentItem: .chats))
      }.store(in: &cancellables)
  }
  
  private func setupChatList() {
    addChild(tableController)
    addChild(searchTableController)
    screenView.listContainerView.addSubview(tableController.view)
    screenView.searchListContainerView.addSubview(searchTableController.view)
    
    tableController.view.snp.makeConstraints {
      $0.top.equalTo(screenView.listContainerView.collectionContainerView.snp.bottom)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    searchTableController.view.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    tableController.didMove(toParent: self)
    searchTableController.didMove(toParent: self)
  }
  
  private func setupRecentContacts() {
    screenView
      .listContainerView
      .collectionView
      .register(ChatListRecentContactCell.self)
    
    collectionDataSource = UICollectionViewDiffableDataSource<SectionId, Contact>(
      collectionView: screenView.listContainerView.collectionView
    ) { collectionView, indexPath, contact in
      let cell: ChatListRecentContactCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
      let title = (contact.nickname ?? contact.username) ?? ""
      cell.setup(title: title, image: contact.photo)
      return cell
    }
    
    screenView.listContainerView.collectionView.delegate = self
    screenView.listContainerView.collectionView.dataSource = collectionDataSource
    
    viewModel
      .recentsPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        collectionDataSource.apply($0)
        shouldBeShowingRecents = $0.numberOfItems > 0
      }.store(in: &cancellables)
  }
  
  private func setupBindings() {
    screenView
      .searchView
      .rightPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentScan())
      }.store(in: &cancellables)
    
    screenView
      .searchView
      .textPublisher
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] query in
        viewModel.updateSearch(query: query)
        screenView.searchListContainerView.emptyView.updateSearched(content: query)
      }.store(in: &cancellables)
    
    Publishers.CombineLatest(
      viewModel.searchPublisher,
      screenView.searchView.textPublisher.removeDuplicates()
    )
    .receive(on: DispatchQueue.main)
    .sink { [unowned self] items, query in
      guard query.isEmpty == false else {
        screenView.searchListContainerView.isHidden = true
        screenView.listContainerView.isHidden = false
        screenView.bringSubviewToFront(screenView.listContainerView)
        return
      }
      screenView.listContainerView.isHidden = true
      screenView.searchListContainerView.isHidden = false
      guard items.numberOfItems > 0 else {
        screenView.searchListContainerView.emptyView.isHidden = false
        screenView.bringSubviewToFront(screenView.searchListContainerView)
        screenView.searchListContainerView.bringSubviewToFront(screenView.searchListContainerView.emptyView)
        return
      }
      screenView.searchListContainerView.bringSubviewToFront(searchTableController.view)
      screenView.searchListContainerView.emptyView.isHidden = true
    }.store(in: &cancellables)
    
    screenView
      .searchView
      .isEditingPublisher
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        isEditingSearch = $0
      }.store(in: &cancellables)
    
    viewModel
      .chatsPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard $0.isEmpty == false else {
          screenView.listContainerView.bringSubviewToFront(screenView.listContainerView.emptyView)
          screenView.listContainerView.emptyView.isHidden = false
          return
        }
        screenView.listContainerView.bringSubviewToFront(tableController.view)
        screenView.listContainerView.emptyView.isHidden = true
      }.store(in: &cancellables)
    
    screenView
      .searchListContainerView
      .emptyView
      .searchButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        navigator.perform(PresentSearch(replacing: false))
      }.store(in: &cancellables)
    
    screenView
      .listContainerView
      .emptyView
      .contactsButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentContactList())
      }.store(in: &cancellables)
    
    viewModel
      .isOnline
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak screenView] connected in
        screenView?.showConnectingBanner(!connected)
      }.store(in: &cancellables)
  }
}

extension ChatListController: UICollectionViewDelegate {
  public func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    if let contact = collectionDataSource.itemIdentifier(for: indexPath) {
      navigator.perform(PresentChat(contact: contact))
    }
  }
}
