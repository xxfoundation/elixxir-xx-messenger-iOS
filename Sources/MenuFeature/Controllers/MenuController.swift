import UIKit
import Shared
import Combine
import DrawerFeature
import DependencyInjection

public enum MenuItem {
  case join
  case scan
  case chats
  case share
  case profile
  case contacts
  case requests
  case settings
  case dashboard
}

public final class MenuController: UIViewController {
  @Dependency var barStylist: StatusBarStylist
  @Dependency var coordinator: MenuCoordinating

  lazy private var screenView = MenuView()

  private let previousItem: MenuItem
  private let viewModel = MenuViewModel()
  private let previousController: UIViewController
  private var cancellables = Set<AnyCancellable>()
  private var drawerCancellables = Set<AnyCancellable>()

  public init(
    _ previousItem: MenuItem,
    _ previousController: UIViewController
  ) {
    self.previousItem = previousItem
    self.previousController = previousController
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

    screenView.select(item: previousItem)
    screenView.xxdkVersionLabel.text = "XXDK \(viewModel.xxdk)"
    screenView.buildLabel.text = Localized.Menu.build(viewModel.build)
    screenView.versionLabel.text = Localized.Menu.version(viewModel.version)
    setupBindings()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    barStylist.styleSubject.send(.lightContent)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    barStylist.styleSubject.send(.darkContent)
  }

  private func setupBindings() {
    screenView.headerView.scanButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dismiss(animated: true) { [weak self] in
          guard let self = self, self.previousItem != .scan else { return }
          self.coordinator.toFlow(.scan, from: self.previousController)
        }
      }.store(in: &cancellables)

    screenView.headerView.nameButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dismiss(animated: true) { [weak self] in
          guard let self = self, self.previousItem != .profile else { return }
          self.coordinator.toFlow(.profile, from: self.previousController)
        }
      }.store(in: &cancellables)

    screenView.scanButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dismiss(animated: true) { [weak self] in
          guard let self = self, self.previousItem != .scan else { return }
          self.coordinator.toFlow(.scan, from: self.previousController)
        }
      }.store(in: &cancellables)

    screenView.chatsButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dismiss(animated: true) { [weak self] in
          guard let self = self, self.previousItem != .chats else { return }
          self.coordinator.toFlow(.chats, from: self.previousController)
        }
      }.store(in: &cancellables)

    screenView.contactsButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dismiss(animated: true) { [weak self] in
          guard let self = self, self.previousItem != .contacts else { return }
          self.coordinator.toFlow(.contacts, from: self.previousController)
        }
      }.store(in: &cancellables)

    screenView.settingsButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dismiss(animated: true) { [weak self] in
          guard let self = self, self.previousItem != .settings else { return }
          self.coordinator.toFlow(.settings, from: self.previousController)
        }
      }.store(in: &cancellables)

    screenView.dashboardButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dismiss(animated: true) { [weak self] in
          guard let self = self, self.previousItem != .dashboard else { return }
          self.presentDrawer(
            title: Localized.ChatList.Dashboard.title,
            subtitle: Localized.ChatList.Dashboard.subtitle,
            actionTitle: Localized.ChatList.Dashboard.open) {
              guard let url = URL(string: "https://dashboard.xx.network") else { return }
              UIApplication.shared.open(url, options: [:])
            }
        }
      }.store(in: &cancellables)

    screenView.requestsButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dismiss(animated: true) { [weak self] in
          guard let self = self, self.previousItem != .requests else { return }
          self.coordinator.toFlow(.requests, from: self.previousController)
        }
      }.store(in: &cancellables)

    screenView.joinButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dismiss(animated: true) { [weak self] in
          guard let self = self, self.previousItem != .join else { return }
          self.presentDrawer(
            title: Localized.ChatList.Join.title,
            subtitle: Localized.ChatList.Join.subtitle,
            actionTitle: Localized.ChatList.Dashboard.open) {
              guard let url = URL(string: "https://xx.network") else { return }
              UIApplication.shared.open(url, options: [:])
            }
        }
      }.store(in: &cancellables)

    screenView.shareButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dismiss(animated: true) { [weak self] in
          guard let self = self, self.previousItem != .share else { return }
          self.coordinator.toActivityController(
            with: [Localized.Menu.shareContent(self.viewModel.referralDeeplink)],
            from: self.previousController
          )
        }
      }.store(in: &cancellables)

    viewModel.requestCount
      .receive(on: DispatchQueue.main)
      .sink { [weak screenView] in screenView?.requestsButton.updateNotification($0) }
      .store(in: &cancellables)
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
        spacingAfter: 39
      ),
      actionButton
    ])

    actionButton.action.receive(on: DispatchQueue.main)
      .sink {
        drawer.dismiss(animated: true) { [weak self] in
          guard let self = self else { return }
          self.drawerCancellables.removeAll()
          action()
        }
      }.store(in: &drawerCancellables)

    coordinator.toDrawer(drawer, from: previousController)
  }
}
