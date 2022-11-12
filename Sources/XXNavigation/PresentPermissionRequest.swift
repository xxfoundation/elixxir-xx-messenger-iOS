import UIKit
import Shared
import Navigation
import DI

public struct PresentPermissionRequest: Navigation.Action {
  public var type: PermissionType
  public var animated: Bool

  public init(
    type: PermissionType,
    animated: Bool = true
  ) {
    self.type = type
    self.animated = animated
  }
}

public struct PresentPermissionRequestNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: (PermissionType) -> UIViewController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentPermissionRequest, completion: @escaping () -> Void) {
    if let topViewController = navigationController().topViewController {
      let modalAction = PresentModal(screen(action.type), from: topViewController)
      navigator.perform(modalAction, completion: completion)
    }
  }

  public init(
    screen: @escaping (PermissionType) -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
