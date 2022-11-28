import UIKit

/// Push view controller on a given navigation controller
public struct Push: Action {
  /// - Parameters:
  ///   - viewController: View controller to which should be pushed
  ///   - navigationController: Navigation controller on which push should happen
  ///   - animated: Animate the transition
  public init(
    _ viewController: UIViewController,
    on navigationController: UINavigationController,
    animated: Bool = true
  ) {
    self.viewController = viewController
    self.navigationController = navigationController
    self.animated = animated
  }

  /// View controller to which should be pushed
  public var viewController: UIViewController

  /// Navigation controller on which push should happen
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `Push` action
public struct PushNavigator: TypedNavigator {
  public init() {}

  public func perform(_ action: Push, completion: @escaping () -> Void) {
    action.navigationController.pushViewController(action.viewController, animated: action.animated)
    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}
