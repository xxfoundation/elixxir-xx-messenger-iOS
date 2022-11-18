import UIKit

/// Pops to root view controller on a given navigation controller
public struct PopToRoot: Action {
  /// - Parameters:
  ///   - navigationController: Navigation controller on which pop should happen
  ///   - animated: Animate the transition
  public init(
    on navigationController: UINavigationController,
    animated: Bool = true
  ) {
    self.navigationController = navigationController
    self.animated = animated
  }

  /// Navigation controller on which pop should happen
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PopToRoot` action
public struct PopToRootNavigator: TypedNavigator {
  public init() {}

  public func perform(_ action: PopToRoot, completion: @escaping () -> Void) {
    action.navigationController.popToRootViewController(animated: action.animated)
    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}
