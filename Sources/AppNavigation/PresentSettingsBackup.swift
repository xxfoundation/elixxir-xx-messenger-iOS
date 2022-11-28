import UIKit

/// Pushes `SettingsBackup` on a given navigation controller
public struct PresentSettingsBackup: Action {
  /// - Parameters:
  ///   - navigationController: Navigation controller on which push should happen
  ///   - animated: Animate the transition
  public init(
    on navigationController: UINavigationController,
    animated: Bool = true
  ) {
    self.navigationController = navigationController
    self.animated = animated
  }

  /// Navigation controller on which push should happen
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentSettingsBackup` action
public struct PresentSettingsBackupNavigator: TypedNavigator {
  /// View controller which should be pushed
  var viewController: () -> UIViewController

  /// - Parameters:
  ///   - viewController: View controller which should be pushed
  public init(_ viewController: @escaping () -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentSettingsBackup, completion: @escaping () -> Void) {
    action.navigationController.pushViewController(viewController(), animated: action.animated)
    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}
