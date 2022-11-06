import UIKit
import Shared
import Combine
import Navigation
import XXNavigation
import DrawerFeature
import DependencyInjection
import ScrollViewController

public final class OnboardingCodeController: UIViewController {
  @Dependency var navigator: Navigator
  @Dependency var barStylist: StatusBarStylist

  private lazy var screenView = OnboardingCodeView()
  private lazy var scrollViewController = ScrollViewController()

  private let isEmail: Bool
  private let content: String
  private let viewModel: OnboardingCodeViewModel
  private var cancellables = Set<AnyCancellable>()
  private var drawerCancellables = Set<AnyCancellable>()

  public init(
    _ isEmail: Bool,
    _ content: String,
    _ confirmationId: String
  ) {
    self.viewModel = .init(
      isEmail: isEmail,
      content: content,
      confirmationId: confirmationId
    )
    self.isEmail = isEmail
    self.content = content
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
      isEmail ?
      Localized.Onboarding.EmailConfirmation.subtitle(content) :
      Localized.Onboarding.PhoneConfirmation.subtitle(content)
    )

    screenView.didTapInfo = { [weak self] in
      guard let self else { return }
      if self.isEmail {
        self.presentInfo(
          title: Localized.Onboarding.EmailConfirmation.Info.title,
          subtitle: Localized.Onboarding.EmailConfirmation.Info.subtitle
        )
      } else {
        self.presentInfo(
          title: Localized.Onboarding.PhoneConfirmation.Info.title,
          subtitle: Localized.Onboarding.PhoneConfirmation.Info.subtitle
        )
      }
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
    screenView
      .inputField
      .textPublisher
      .sink { [unowned self] in
        viewModel.didInput($0)
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .map(\.status)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.update(status: $0)
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .map(\.didConfirm)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard $0 == true else { return }
        if isEmail {
          navigator.perform(PresentOnboardingPhone())
        } else {
          navigator.perform(PresentChatList())
        }
      }.store(in: &cancellables)

    screenView
      .nextButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        viewModel.didTapNext()
      }.store(in: &cancellables)

    screenView
      .resendButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        viewModel.didTapResend()
      }.store(in: &cancellables)

    viewModel
      .statePublisher
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

    navigator.perform(PresentDrawer())
  }
}
