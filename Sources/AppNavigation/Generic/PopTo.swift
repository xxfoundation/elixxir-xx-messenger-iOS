import UIKit

/// Pop to the view controller on a given navigation controller
public struct PopTo: Action {
  /// - Parameters:
  ///   - viewController: View controller to which should pop
  ///   - navigationController: Navigation controller on which pop should happen
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

  /// View controller to which should pop
  public var viewController: UIViewController

  /// Navigation controller on which pop should happen
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PopTo` action
public struct PopToNavigator: TypedNavigator {
  public init() {}

  public func perform(_ action: PopTo, completion: @escaping () -> Void) {
    action.navigationController.popToViewController(
      action.viewController,
      animated: action.animated
    )
    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}
