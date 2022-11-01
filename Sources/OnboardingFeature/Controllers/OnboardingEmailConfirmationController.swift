import HUD
import UIKit
import Shared
import Models
import Combine
import DrawerFeature
import DependencyInjection
import ScrollViewController

public final class OnboardingEmailConfirmationController: UIViewController {
  @Dependency var hud: HUD
  @Dependency var barStylist: StatusBarStylist
  @Dependency var coordinator: OnboardingCoordinating

  lazy private var screenView = OnboardingEmailConfirmationView()
  lazy private var scrollViewController = ScrollViewController()

  private var cancellables = Set<AnyCancellable>()
  private let completion: (UIViewController) -> Void
  private var drawerCancellables = Set<AnyCancellable>()
  private let viewModel: OnboardingEmailConfirmationViewModel

  public init(
    _ confirmation: AttributeConfirmation,
    _ completion: @escaping (UIViewController) -> Void
  ) {
    self.completion = completion
    self.viewModel = OnboardingEmailConfirmationViewModel(confirmation)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

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

    screenView.setupSubtitle(
      Localized.Onboarding.EmailConfirmation.subtitle(viewModel.confirmation.content)
    )

    screenView.didTapInfo = { [weak self] in
      self?.presentInfo(
        title: Localized.Onboarding.EmailConfirmation.Info.title,
        subtitle: Localized.Onboarding.EmailConfirmation.Info.subtitle
      )
    }
  }

  private func setupScrollView() {
    addChild(scrollViewController)
    view.addSubview(scrollViewController.view)
    scrollViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
    scrollViewController.didMove(toParent: self)
    scrollViewController.contentView = screenView
    scrollViewController.scrollView.backgroundColor = Asset.neutralWhite.color
  }

  private func setupBindings() {
    viewModel.hud.receive(on: DispatchQueue.main)
      .sink { [hud] in hud.update(with: $0) }
      .store(in: &cancellables)

    screenView.inputField.textPublisher
      .sink { [unowned self] in viewModel.didInput($0) }
      .store(in: &cancellables)

    viewModel.state
      .map(\.status)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in screenView.update(status: $0) }
      .store(in: &cancellables)

    screenView.nextButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in viewModel.didTapNext() }
      .store(in: &cancellables)

    viewModel.completionPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in completion(self) }
      .store(in: &cancellables)

    screenView.resendButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in viewModel.didTapResend() }
      .store(in: &cancellables)

    viewModel.state
      .map(\.resendDebouncer)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.resendButton.isEnabled = $0 == 0

        if $0 == 0 {
          screenView.resendButton.setTitle(Localized.Profile.Code.resend(""), for: .normal)
        } else {
          screenView.resendButton.setTitle(Localized.Profile.Code.resend("(\($0))"), for: .disabled)
        }
      }.store(in: &cancellables)
  }

  private func presentInfo(title: String, subtitle: String) {
    let actionButton = CapsuleButton()
    actionButton.set(style: .seeThrough, title: Localized.Settings.InfoDrawer.action)

    let drawer = DrawerController(with: [
      DrawerText(
        font: Fonts.Mulish.bold.font(size: 26.0),
        text: title,
        color: Asset.neutralActive.color,
        alignment: .left,
        spacingAfter: 19
      ),
      DrawerText(
        font: Fonts.Mulish.regular.font(size: 16.0),
        text: subtitle,
        color: Asset.neutralBody.color,
        alignment: .left,
        lineHeightMultiple: 1.1,
        spacingAfter: 37
      ),
      DrawerStack(views: [
        actionButton,
        FlexibleSpace()
      ])
    ])

    actionButton.publisher(for: .touchUpInside)
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
