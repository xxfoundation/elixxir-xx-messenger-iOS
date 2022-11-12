import UIKit
import Shared
import Combine
import Navigation
import DrawerFeature
import DI
import ScrollViewController

public final class OnboardingUsernameController: UIViewController {
  @Dependency var navigator: Navigator
  @Dependency var barStylist: StatusBarStylist

  private lazy var screenView = OnboardingUsernameView()
  private lazy var scrollViewController = ScrollViewController()

  private var cancellables = Set<AnyCancellable>()
  private let viewModel = OnboardingUsernameViewModel()
  private var drawerCancellables = Set<AnyCancellable>()

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = ""
    barStylist.styleSubject.send(.darkContent)
    navigationController?.navigationBar.customize(translucent: true)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupScrollView()
    setupBindings()
    screenView.didTapInfo = { [weak self] in
      guard let self else { return }
      self.presentInfo(
        title: Localized.Onboarding.Username.Info.title,
        subtitle: Localized.Onboarding.Username.Info.subtitle,
        urlString: "https://links.xx.network/ud"
      )
    }
  }

  private func setupScrollView() {
    scrollViewController.scrollView.backgroundColor = .white
    addChild(scrollViewController)
    view.addSubview(scrollViewController.view)
    scrollViewController.view.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    scrollViewController.didMove(toParent: self)
    scrollViewController.contentView = screenView
  }

  private func setupBindings() {
    screenView
      .inputField
      .textPublisher
      .removeDuplicates()
      .compactMap { $0 }
      .sink { [unowned self] in
        viewModel.didInput($0)
      }.store(in: &cancellables)

    screenView
      .restoreView
      .restoreButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentRestoreList())
      }.store(in: &cancellables)

    screenView
      .inputField
      .returnPublisher
      .sink { [unowned self] in
        if screenView.nextButton.isEnabled {
          viewModel.didTapRegister()
        } else {
          screenView.inputField.endEditing(true)
        }
      }.store(in: &cancellables)

    screenView
      .nextButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        viewModel.didTapRegister()
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard $0.didConfirm == true else { return }
        navigator.perform(PresentOnboardingWelcome())
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .map(\.status)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.update(status: $0)
      }.store(in: &cancellables)
  }

  private func presentInfo(
    title: String,
    subtitle: String,
    urlString: String = ""
  ) {
    let actionButton = CapsuleButton()
    actionButton.set(
      style: .seeThrough,
      title: Localized.Settings.InfoDrawer.action
    )
    actionButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) {
          self.drawerCancellables.removeAll()
        }
      }.store(in: &drawerCancellables)

    navigator.perform(PresentDrawer(items: [
      DrawerText(
        font: Fonts.Mulish.bold.font(size: 26.0),
        text: title,
        color: Asset.neutralActive.color,
        alignment: .left,
        spacingAfter: 19
      ),
      DrawerLinkText(
        text: subtitle,
        urlString: urlString,
        spacingAfter: 37
      ),
      DrawerStack(views: [
        actionButton,
        FlexibleSpace()
      ])
    ]))
  }
}
