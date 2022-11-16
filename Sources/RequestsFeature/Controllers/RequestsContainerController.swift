import UIKit
import Shared
import Combine
import Navigation
import ContactFeature
import DI

public final class RequestsContainerController: UIViewController {
  @Dependency var navigator: Navigator
  @Dependency var barStylist: StatusBarStylist

  private lazy var screenView = RequestsContainerView()
  private var cancellables = Set<AnyCancellable>()

  public override func loadView() {
    view = screenView
    screenView.scrollView.delegate = self

    addChild(screenView.sentController)
    addChild(screenView.failedController)
    addChild(screenView.receivedController)

    screenView.sentController.didMove(toParent: self)
    screenView.failedController.didMove(toParent: self)
    screenView.receivedController.didMove(toParent: self)

    screenView.bringSubviewToFront(screenView.segmentedControl)
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    barStylist.styleSubject.send(.darkContent)

    navigationController?.navigationBar
      .customize(backgroundColor: Asset.neutralWhite.color)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupBindings()

    if let stack = navigationController?.viewControllers, stack.count > 1 {
      if stack[stack.count - 2].isKind(of: ContactController.self) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
          guard let self else { return }

          let point = CGPoint(x: self.screenView.frame.width, y: 0.0)
          self.screenView.scrollView.setContentOffset(point, animated: true)
        }
      }
    }
  }

  private func setupNavigationBar() {
    navigationItem.backButtonTitle = ""

    let titleLabel = UILabel()
    titleLabel.text = Localized.Requests.title
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
  }

  private func setupBindings() {
    screenView
      .sentController
      .connectionsPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentSearch(
          searching: nil,
          replacing: false,
          on: navigationController!
        ))
      }.store(in: &cancellables)

    screenView
      .segmentedControl
      .receivedRequestsButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] _ in
        screenView.scrollView.setContentOffset(.zero, animated: true)
      }.store(in: &cancellables)

    screenView
      .segmentedControl
      .sentRequestsButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] _ in
        let point = CGPoint(x: screenView.frame.width, y: 0.0)
        screenView.scrollView.setContentOffset(point, animated: true)
      }.store(in: &cancellables)

    screenView
      .segmentedControl
      .failedRequestsButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] _ in
        let point = CGPoint(x: screenView.frame.width * 2.0, y: 0.0)
        screenView.scrollView.setContentOffset(point, animated: true)
      }.store(in: &cancellables)
  }

  @objc private func didTapMenu() {
    navigator.perform(PresentMenu(currentItem: .requests, from: self))
  }
}

extension RequestsContainerController: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    screenView.segmentedControl.updateSwipePercentage(scrollView.contentOffset.x / view.frame.width)
  }
}
