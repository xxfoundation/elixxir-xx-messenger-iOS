import UIKit

/// Pushes `ProfilePhone` on a given navigation controller
public struct PresentProfilePhone: Action {
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

/// Performs `PresentProfilePhone` action
public struct PresentProfilePhoneNavigator: TypedNavigator {
  /// View controller which should be pushed
  var viewController: () -> UIViewController

  /// - Parameters:
  ///   - viewController: View controller which should be pushed
  public init(_ viewController: @escaping () -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentProfilePhone, completion: @escaping () -> Void) {
    action.navigationController.pushViewController(viewController(), animated: action.animated)
    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}
