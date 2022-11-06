import UIKit
import Shared
import Combine
import XXModels
import DrawerFeature
import DependencyInjection

public final class SearchContainerController: UIViewController {
  @Dependency var barStylist: StatusBarStylist
  @Dependency var coordinator: SearchCoordinating

  private lazy var screenView = SearchContainerView()

  private var contentOffset: CGPoint?
  private var cancellables = Set<AnyCancellable>()
  private let leftController: SearchLeftController
  private let viewModel = SearchContainerViewModel()
  private let rightController = SearchRightController()
  private var drawerCancellables = Set<AnyCancellable>()

  public init(_ invitation: String? = nil) {
    self.leftController = .init(invitation)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func loadView() {
    view = screenView
    embedControllers()
  }

  public func startSearchingFor(_ string: String) {
    leftController.viewModel.invitation = string
    leftController.viewModel.viewDidAppear()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = ""
    barStylist.styleSubject.send(.darkContent)
    navigationController?.navigationBar.customize(
      backgroundColor: Asset.neutralWhite.color
    )

    if let contentOffset = self.contentOffset {
      screenView.scrollView.setContentOffset(contentOffset, animated: true)
    }
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    contentOffset = screenView.scrollView.contentOffset
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.didAppear()
    rightController.viewModel.viewWillAppear()
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupBindings()
  }

  private func setupNavigationBar() {
    let title = UILabel()
    title.text = Localized.Ud.title
    title.textColor = Asset.neutralActive.color
    title.font = Fonts.Mulish.semiBold.font(size: 18.0)

    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: title)
    navigationItem.leftItemsSupplementBackButton = true
  }

  private func setupBindings() {
    screenView.segmentedControl
      .actionPublisher
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        if $0 == .qr {
          let point = CGPoint(x: screenView.frame.width, y: 0.0)
          screenView.scrollView.setContentOffset(point, animated: true)
          leftController.endEditing()
        } else {
          screenView.scrollView.setContentOffset(.zero, animated: true)
          leftController.viewModel.didSelectItem($0)
        }
      }.store(in: &cancellables)

    viewModel.coverTrafficPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in presentCoverTrafficDrawer() }
      .store(in: &cancellables)
  }

  private func embedControllers() {
    addChild(leftController)
    addChild(rightController)

    screenView.scrollView.addSubview(leftController.view)
    screenView.scrollView.addSubview(rightController.view)

    leftController.view.snp.makeConstraints {
      $0.top.equalTo(screenView.segmentedControl.snp.bottom)
      $0.width.equalTo(screenView)
      $0.bottom.equalTo(screenView)
      $0.left.equalToSuperview()
      $0.right.equalTo(rightController.view.snp.left)
    }

    rightController.view.snp.makeConstraints {
      $0.top.equalTo(screenView.segmentedControl.snp.bottom)
      $0.width.equalTo(screenView)
      $0.bottom.equalTo(screenView)
    }

    leftController.didMove(toParent: self)
    rightController.didMove(toParent: self)
  }
}

extension SearchContainerController {
  private func presentCoverTrafficDrawer() {
    let enableButton = CapsuleButton()
    enableButton.set(
      style: .brandColored,
      title: Localized.ChatList.Traffic.positive
    )

    let dismissButton = CapsuleButton()
    dismissButton.set(
      style: .seeThrough,
      title: Localized.ChatList.Traffic.negative
    )

    let drawer = DrawerController([
      DrawerText(
        font: Fonts.Mulish.bold.font(size: 26.0),
        text: Localized.ChatList.Traffic.title,
        color: Asset.neutralActive.color,
        alignment: .left,
        spacingAfter: 19
      ),
      DrawerText(
        font: Fonts.Mulish.regular.font(size: 16.0),
        text: Localized.ChatList.Traffic.subtitle,
        color: Asset.neutralBody.color,
        alignment: .left,
        lineHeightMultiple: 1.1,
        spacingAfter: 39
      ),
      DrawerStack(
        axis: .horizontal,
        spacing: 20,
        distribution: .fillEqually,
        views: [enableButton, dismissButton]
      )
    ])

    enableButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink {
        drawer.dismiss(animated: true) { [weak self] in
          guard let self = self else { return }
          self.drawerCancellables.removeAll()
          self.viewModel.didEnableCoverTraffic()
        }
      }.store(in: &drawerCancellables)

    dismissButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink {
        drawer.dismiss(animated: true) { [weak self] in
          guard let self = self else { return }
          self.drawerCancellables.removeAll()
        }
      }.store(in: &drawerCancellables)

    coordinator.toDrawer(drawer, from: self)
  }
}
