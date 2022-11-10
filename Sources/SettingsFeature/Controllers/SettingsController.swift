import UIKit
import Shared
import Combine
import XXNavigation
import DrawerFeature
import DependencyInjection
import ScrollViewController

public final class SettingsController: UIViewController {
  @Dependency var navigator: Navigator
  @Dependency var barStylist: StatusBarStylist

  private lazy var scrollViewController = ScrollViewController()
  private lazy var screenView = SettingsView {
    switch $0 {
    case .icognitoKeyboard:
      self.presentInfo(
        title: Localized.Settings.InfoDrawer.Icognito.title,
        subtitle: Localized.Settings.InfoDrawer.Icognito.subtitle
      )
    case .biometrics:
      self.presentInfo(
        title: Localized.Settings.InfoDrawer.Biometrics.title,
        subtitle: Localized.Settings.InfoDrawer.Biometrics.subtitle
      )
    case .notifications:
      self.presentInfo(
        title: Localized.Settings.InfoDrawer.Notifications.title,
        subtitle: Localized.Settings.InfoDrawer.Notifications.subtitle,
        urlString: "https://links.xx.network/denseids"
      )

    case .dummyTraffic:
      self.presentInfo(
        title: Localized.Settings.InfoDrawer.Traffic.title,
        subtitle: Localized.Settings.InfoDrawer.Traffic.subtitle,
        urlString: "https://links.xx.network/covertraffic"
      )
    }
  }

  private let viewModel = SettingsViewModel()
  private var cancellables = Set<AnyCancellable>()
  private var drawerCancellables = Set<AnyCancellable>()

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    barStylist.styleSubject.send(.darkContent)
    navigationController?.navigationBar
      .customize(backgroundColor: Asset.neutralWhite.color)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    setupNavigationBar()
    setupScrollView()
    setupBindings()

    viewModel.loadCachedSettings()
  }

  private func setupNavigationBar() {
    navigationItem.backButtonTitle = ""

    let titleLabel = UILabel()
    titleLabel.text = Localized.Settings.title
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

  private func setupScrollView() {
    scrollViewController.view.backgroundColor = Asset.neutralWhite.color
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
      .inAppNotifications
      .switcherView
      .publisher(for: .valueChanged)
      .sink { [weak viewModel] in
        viewModel?.didToggleInAppNotifications()
      }.store(in: &cancellables)

    screenView
      .dummyTraffic
      .switcherView
      .publisher(for: .valueChanged)
      .sink { [weak viewModel] in
        viewModel?.didToggleDummyTraffic()
      }.store(in: &cancellables)

    screenView
      .remoteNotifications
      .switcherView
      .publisher(for: .valueChanged)
      .sink { [weak viewModel] in
        viewModel?.didTogglePushNotifications()
      }.store(in: &cancellables)

    screenView
      .hideActiveApp
      .switcherView
      .publisher(for: .valueChanged)
      .sink { [weak viewModel] in
        viewModel?.didToggleHideActiveApps()
      }.store(in: &cancellables)

    screenView
      .icognitoKeyboard
      .switcherView
      .publisher(for: .valueChanged)
      .sink { [weak viewModel] in
        viewModel?.didToggleIcognitoKeyboard()
      }.store(in: &cancellables)

    screenView
      .biometrics
      .switcherView
      .publisher(for: .valueChanged)
      .sink { [weak viewModel] in
        viewModel?.didToggleBiometrics()
      }.store(in: &cancellables)

    screenView
      .privacyPolicyButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentDrawer(
          title: Localized.Settings.Drawer.title(Localized.Settings.privacyPolicy),
          subtitle: Localized.Settings.Drawer.subtitle(Localized.Settings.privacyPolicy),
          actionTitle: Localized.ChatList.Dashboard.open) {
            guard let url = URL(string: "https://elixxir.io/privategrity-corporation-privacy-policy/") else { return }
            UIApplication.shared.open(url, options: [:])
          }
      }.store(in: &cancellables)

    screenView
      .disclosuresButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        presentDrawer(
          title: Localized.Settings.Drawer.title(Localized.Settings.disclosures),
          subtitle: Localized.Settings.Drawer.subtitle(Localized.Settings.disclosures),
          actionTitle: Localized.ChatList.Dashboard.open) {
            guard let url = URL(string: "https://elixxir.io/privategrity-corporation-terms-of-use/") else { return }
            UIApplication.shared.open(url, options: [:])
          }
      }.store(in: &cancellables)

    screenView
      .deleteButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentSettingsAccountDelete())
      }.store(in: &cancellables)

    screenView
      .accountBackupButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentSettingsBackup())
      }.store(in: &cancellables)

    screenView
      .advancedButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(PresentSettingsAdvanced())
      }.store(in: &cancellables)

    viewModel
      .state
      .map(\.isBiometricsPossible)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak screenView] in
        screenView?.biometrics.switcherView.isEnabled = $0
      }.store(in: &cancellables)

    viewModel
      .state
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] state in
        screenView.biometrics.switcherView.setOn(state.isBiometricsEnabled, animated: true)
        screenView.hideActiveApp.switcherView.setOn(state.isHideActiveApps, animated: true)
        screenView.icognitoKeyboard.switcherView.setOn(state.isIcognitoKeyboard, animated: true)
        screenView.inAppNotifications.switcherView.setOn(state.isInAppNotification, animated: true)
        screenView.remoteNotifications.switcherView.setOn(state.isPushNotification, animated: true)
        screenView.dummyTraffic.switcherView.setOn(state.isDummyTrafficOn, animated: true)
      }.store(in: &cancellables)
  }

  private func presentDrawer(
    title: String,
    subtitle: String,
    actionTitle: String,
    action: @escaping () -> Void
  ) {
    let actionButton = CapsuleButton()
    actionButton.setStyle(.red)
    actionButton.setTitle(actionTitle, for: .normal)

    let cancelButton = CapsuleButton()
    cancelButton.setStyle(.seeThrough)
    cancelButton.setTitle(Localized.ChatList.Dashboard.cancel, for: .normal)

    actionButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
          action()
        }
      }.store(in: &drawerCancellables)

    cancelButton.publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
        }
      }.store(in: &drawerCancellables)

    navigator.perform(PresentDrawer(items: [
      DrawerImage(
        image: Asset.drawerNegative.image
      ),
      DrawerText(
        font: Fonts.Mulish.semiBold.font(size: 18.0),
        text: title,
        color: Asset.neutralActive.color
      ),
      DrawerText(
        font: Fonts.Mulish.semiBold.font(size: 14.0),
        text: subtitle,
        color: Asset.neutralWeak.color,
        lineHeightMultiple: 1.35,
        spacingAfter: 25
      ),
      DrawerStack(
        spacing: 20.0,
        views: [actionButton, cancelButton]
      )
    ]))
  }

  @objc private func didTapMenu() {
    navigator.perform(PresentMenu(currentItem: .settings))
  }
}

extension SettingsController {
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
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
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
