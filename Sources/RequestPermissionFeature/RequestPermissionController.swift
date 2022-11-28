import UIKit
import Shared
import Combine
import AppCore
import Dependencies
import AppResources
import AppNavigation
import PermissionsFeature

public final class RequestPermissionController: UIViewController {
  @Dependency(\.app.statusBar) var statusBar: StatusBarStylist
  @Dependency(\.permissions) var permissions: PermissionsManager

  private lazy var screenView = RequestPermissionView()

  private let permissionType: PermissionType
  private var cancellables = Set<AnyCancellable>()

  public override func loadView() {
    view = screenView
  }

  public init(_ permissionType: PermissionType) {
    self.permissionType = permissionType
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { nil }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    statusBar.set(.darkContent)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    switch permissionType {
    case .camera:
      screenView.setup(
        title: Localized.Chat.Actions.Permission.Camera.title,
        subtitle: Localized.Chat.Actions.Permission.Camera.subtitle,
        image: Asset.permissionCamera.image
      )
    case .library:
      screenView.setup(
        title: Localized.Chat.Actions.Permission.Library.title,
        subtitle: Localized.Chat.Actions.Permission.Library.subtitle,
        image: Asset.permissionLibrary.image
      )
    case .microphone:
      screenView.setup(
        title: Localized.Chat.Actions.Permission.Microphone.title,
        subtitle: Localized.Chat.Actions.Permission.Microphone.subtitle,
        image: Asset.permissionMicrophone.image
      )
    }

    screenView
      .notNowButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        dismiss(animated: true)
      }.store(in: &cancellables)

    screenView
      .continueButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        switch permissionType {
        case .camera:
          permissions.camera.request { [weak self] _ in
            guard let self else { return }
            self.shouldDismissModal()
          }
        case .library:
          permissions.library.request { [weak self] _ in
            guard let self else { return }
            self.shouldDismissModal()
          }
        case .microphone:
          permissions.microphone.request { [weak self] _ in
            guard let self else { return }
            self.shouldDismissModal()
          }
        }
      }.store(in: &cancellables)
  }

  private func shouldDismissModal() {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      self.dismiss(animated: true)
    }
  }
}
