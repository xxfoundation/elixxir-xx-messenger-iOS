import UIKit
import Shared
import Combine
import XXNavigation
import DependencyInjection

public final class RequestPermissionController: UIViewController {
  @Dependency var navigator: Navigator
  @Dependency var barStylist: StatusBarStylist
  @Dependency var permissions: PermissionHandling

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
    navigationItem.backButtonTitle = ""
    barStylist.styleSubject.send(.darkContent)
    navigationController?.navigationBar
      .customize(backgroundColor: Asset.neutralWhite.color)
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
        navigator.perform(DismissModal(from: self))
      }.store(in: &cancellables)

    screenView
      .continueButton
      .publisher(for: .touchUpInside)
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        switch permissionType {
        case .camera:
          permissions.requestCamera { [weak self] _ in
            guard let self else { return }
            self.shouldDismissModal()
          }
        case .library:
          permissions.requestPhotos { [weak self] _ in
            guard let self else { return }
            self.shouldDismissModal()
          }
        case .microphone:
          permissions.requestMicrophone { [weak self] _ in
            guard let self else { return }
            self.shouldDismissModal()
          }
        }
      }.store(in: &cancellables)
  }

  private func shouldDismissModal() {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      self.navigator.perform(DismissModal(from: self))
    }
  }
}
