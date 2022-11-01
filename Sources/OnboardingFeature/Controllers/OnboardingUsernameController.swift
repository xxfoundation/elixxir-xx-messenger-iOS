import UIKit
import Shared
import Combine
import DrawerFeature
import DependencyInjection
import ScrollViewController

public final class OnboardingUsernameController: UIViewController {
  @Dependency var barStylist: StatusBarStylist
  @Dependency var coordinator: OnboardingCoordinating

  lazy private var screenView = OnboardingUsernameView()
  lazy private var scrollViewController = ScrollViewController()

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
      self?.presentInfo(
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
    scrollViewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
    scrollViewController.didMove(toParent: self)
    scrollViewController.contentView = screenView
  }

  private func setupBindings() {
    screenView.inputField.textPublisher
      .removeDuplicates()
      .compactMap { $0 }
      .sink { [unowned self] in viewModel.didInput($0) }
      .store(in: &cancellables)

    screenView.restoreView.restoreButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in coordinator.toRestoreList(from: self) }
      .store(in: &cancellables)

    screenView.inputField.returnPublisher
      .sink { [unowned self] in
        if screenView.nextButton.isEnabled {
          viewModel.didTapRegister()
        } else {
          screenView.inputField.endEditing(true)
        }
      }.store(in: &cancellables)

    screenView.nextButton.publisher(for: .touchUpInside)
      .sink { [unowned self] in viewModel.didTapRegister() }
      .store(in: &cancellables)

    viewModel.greenPublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in coordinator.toWelcome(from: self) }
      .store(in: &cancellables)

    viewModel.state
      .map(\.status)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in screenView.update(status: $0) }
      .store(in: &cancellables)
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

    let drawer = DrawerController(with: [
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
