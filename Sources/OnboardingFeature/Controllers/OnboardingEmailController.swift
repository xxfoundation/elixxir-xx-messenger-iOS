import UIKit
import Shared
import Combine
import AppCore
import AppResources
import Dependencies
import AppNavigation
import DrawerFeature
import ScrollViewController

public final class OnboardingEmailController: UIViewController {
  @Dependency(\.navigator) var navigator: Navigator
  @Dependency(\.app.statusBar) var statusBar: StatusBarStylist

  private lazy var screenView = OnboardingEmailView()
  private lazy var scrollViewController = ScrollViewController()

  private var cancellables = Set<AnyCancellable>()
  private let viewModel = OnboardingEmailViewModel()
  private var drawerCancellables = Set<AnyCancellable>()

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = " "
    statusBar.set(.darkContent)
    navigationController?.navigationBar.customize(translucent: true)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupScrollView()
    setupBindings()
    screenView.didTapInfo = { [weak self] in
      guard let self else { return }
      self.presentInfo(
        title: Localized.Onboarding.Email.Info.title,
        subtitle: Localized.Onboarding.Email.Info.subtitle,
        urlString: "https://links.xx.network/ud"
      )
    }
  }

  private func setupScrollView() {
    addChild(scrollViewController)
    view.addSubview(scrollViewController.view)
    scrollViewController.view.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    scrollViewController.didMove(toParent: self)
    scrollViewController.contentView = screenView
    scrollViewController.scrollView.backgroundColor = Asset.neutralWhite.color
  }

  private func setupBindings() {
    screenView
      .inputField
      .textPublisher
      .sink { [unowned self] in
        viewModel.didInput($0)
      }.store(in: &cancellables)

    screenView
      .inputField
      .returnPublisher
      .sink { [unowned self] in
        screenView.inputField.endEditing(true)
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard let id = $0.confirmationId else { return }
        viewModel.clearUp()
        navigator.perform(
          PresentOnboardingCode(
            isEmail: true,
            content: $0.input,
            confirmationId: id,
            on: navigationController!
          )
        )
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .map(\.status)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.update(status: $0)
      }.store(in: &cancellables)

    screenView
      .nextButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        viewModel.didTapNext()
      }.store(in: &cancellables)

    screenView
      .skipButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        navigator.perform(PresentOnboardingPhone(on: navigationController!))
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
    ], isDismissable: true, from: self))
  }
}
