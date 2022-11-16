import UIKit
import Shared
import Combine
import Navigation
import AppResources
import DrawerFeature
import StatusBarFeature
import ScrollViewController
import ComposableArchitecture

public final class OnboardingPhoneController: UIViewController {
  @Dependency(\.navigator) var navigator: Navigator
  @Dependency(\.statusBar) var statusBar: StatusBarStyleManager

  private lazy var screenView = OnboardingPhoneView()
  private lazy var scrollViewController = ScrollViewController()

  private var cancellables = Set<AnyCancellable>()
  private let viewModel = OnboardingPhoneViewModel()
  private var drawerCancellables = Set<AnyCancellable>()

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationItem.backButtonTitle = ""
    statusBar.update(.darkContent)
    navigationController?.navigationBar.customize(translucent: true)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    setupScrollView()
    setupBindings()
    screenView.didTapInfo = { [weak self] in
      guard let self else { return }
      self.presentInfo(
        title: Localized.Onboarding.Phone.Info.title,
        subtitle: Localized.Onboarding.Phone.Info.subtitle,
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
        navigator.perform(PresentChatList(on: navigationController!))
      }.store(in: &cancellables)

    screenView
      .inputField
      .codePublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentCountryList(completion: { [weak self] in
          guard let self else { return }
          self.navigator.perform(DismissModal(from: self))
          self.viewModel.didChooseCountry($0 as! Country)
        }, from: self))
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard let id = $0.confirmationId, let content = $0.content else { return }
        viewModel.clearUp()
        navigator.perform(
          PresentOnboardingCode(
            isEmail: false,
            content: content,
            confirmationId: id,
            on: navigationController!
          )
        )
      }.store(in: &cancellables)

    viewModel
      .statePublisher
      .map(\.country)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        screenView.inputField.set(prefix: $0.prefixWithFlag)
        screenView.inputField.update(placeholder: $0.example)
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
