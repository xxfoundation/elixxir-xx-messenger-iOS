import UIKit

/// Sets view controllers on a given navigation controller
public struct SetStack: Action {
  /// - Parameters:
  ///   - viewControllers: View controllers that should be set
  ///   - navigationController: Navigation controller on which view controllers should be set
  ///   - animated: Animate the transition
  public init(
    _ viewControllers: [UIViewController],
    on navigationController: UINavigationController,
    animated: Bool = true
  ) {
    self.viewControllers = viewControllers
    self.navigationController = navigationController
    self.animated = animated
  }

  /// View controllers that should be set
  public var viewControllers: [UIViewController]

  /// Navigation controller on which view controllers should be set
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `SetStack` action
public struct SetStackNavigator: TypedNavigator {
  public init() {}

  public func perform(_ action: SetStack, completion: @escaping () -> Void) {
    action.navigationController.setViewControllers(
      action.viewControllers,
      animated: action.animated
    )
    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}
