import UIKit
import Shared
import Combine
import AppCore
import Dependencies
import AppResources
import AppNavigation
import DrawerFeature

public final class MenuController: UIViewController {
  @Dependency(\.navigator) var navigator: Navigator
  @Dependency(\.app.statusBar) var statusBar: StatusBarStylist

  private lazy var screenView = MenuView()

  private let currentItem: MenuItem
  private let viewModel = MenuViewModel()
  private var cancellables = Set<AnyCancellable>()
  private var drawerCancellables = Set<AnyCancellable>()

  private var navController: UINavigationController?

  public init(
    _ currentItem: MenuItem,
    _ navController: UINavigationController? = nil
  ) {
    self.currentItem = currentItem
    self.navController = navController
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func loadView() {
    view = screenView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    screenView.headerView.set(
      username: viewModel.username,
      image: viewModel.avatar
    )

    switch currentItem {
    case .scan:
      screenView.scanButton.set(color: Asset.brandPrimary.color)
    case .chats:
      screenView.chatsButton.set(color: Asset.brandPrimary.color)
    case .contacts:
      screenView.contactsButton.set(color: Asset.brandPrimary.color)
    case .requests:
      screenView.requestsButton.set(color: Asset.brandPrimary.color)
    case .settings:
      screenView.settingsButton.set(color: Asset.brandPrimary.color)
    default:
      break
    }

    screenView.xxdkVersionLabel.text = "XXDK \(viewModel.xxdk)"
    screenView.buildLabel.text = Localized.Menu.build(viewModel.build)
    screenView.versionLabel.text = Localized.Menu.version(viewModel.version)
    setupBindings()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    statusBar.set(.lightContent)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    statusBar.set(.darkContent)
  }

  private func setupBindings() {
    screenView
      .headerView
      .scanButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self, self.currentItem != .scan else { return }
          self.navigator.perform(PresentScan(on: self.navController!))
        }
      }.store(in: &cancellables)

    screenView
      .headerView
      .nameButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self, self.currentItem != .profile else { return }
          self.navigator.perform(PresentProfile(on: self.navController!))
        }
      }.store(in: &cancellables)

    screenView
      .scanButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self, self.currentItem != .scan else { return }
          self.navigator.perform(PresentScan(on: self.navController!))
        }
      }.store(in: &cancellables)

    screenView
      .chatsButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self, self.currentItem != .chats else { return }
          self.navigator.perform(PresentChatList(on: self.navController!))
        }
      }.store(in: &cancellables)

    screenView
      .contactsButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self, self.currentItem != .contacts else { return }
          self.navigator.perform(PresentContactList(on: self.navController!))
        }
      }.store(in: &cancellables)

    screenView
      .settingsButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self, self.currentItem != .settings else { return }
          self.navigator.perform(PresentSettings(on: self.navController!))
        }
      }.store(in: &cancellables)

    screenView
      .dashboardButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self, self.currentItem != .dashboard else { return }
          self.presentDrawer(
            title: Localized.ChatList.Dashboard.title,
            subtitle: Localized.ChatList.Dashboard.subtitle,
            actionTitle: Localized.ChatList.Dashboard.open) {
              guard let url = URL(string: "https://dashboard.xx.network") else { return }
              UIApplication.shared.open(url, options: [:])
            }
        }
      }.store(in: &cancellables)

    screenView
      .requestsButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self, self.currentItem != .requests else { return }
          self.navigator.perform(PresentRequests(on: self.navController!))
        }
      }.store(in: &cancellables)

    screenView
      .joinButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self, self.currentItem != .join else { return }
          self.presentDrawer(
            title: Localized.ChatList.Join.title,
            subtitle: Localized.ChatList.Join.subtitle,
            actionTitle: Localized.ChatList.Dashboard.open) {
              guard let url = URL(string: "https://xx.network") else { return }
              UIApplication.shared.open(url, options: [:])
            }
        }
      }.store(in: &cancellables)

    screenView
      .shareButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self, self.currentItem != .share else { return }
          self.navigator.perform(PresentActivitySheet(items: [
            Localized.Menu.shareContent(self.viewModel.referralDeeplink)
          ], from: self.navController!.topViewController!))
        }
      }.store(in: &cancellables)

    viewModel
      .requestCount
      .receive(on: DispatchQueue.main)
      .sink { [weak screenView] in
        screenView?.requestsButton.updateNotification($0)
      }.store(in: &cancellables)
  }

  private func presentDrawer(
    title: String,
    subtitle: String,
    actionTitle: String,
    action: @escaping () -> Void
  ) {
    let actionButton = DrawerCapsuleButton(model: .init(
      title: actionTitle,
      style: .red
    ))

    actionButton
      .action
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        navigator.perform(DismissModal(from: self)) { [weak self] in
          guard let self else { return }
          self.drawerCancellables.removeAll()
          action()
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
      DrawerText(
        font: Fonts.Mulish.regular.font(size: 16.0),
        text: subtitle,
        color: Asset.neutralBody.color,
        alignment: .left,
        lineHeightMultiple: 1.1,
        spacingAfter: 39
      ),
      actionButton
    ], isDismissable: true, from: navController!.topViewController!))
  }
}
