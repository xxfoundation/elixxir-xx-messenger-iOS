import UIKit

/// Sets or Pushes `TermsAndConditions` on a given navigation controller
public struct PresentTermsAndConditions: Action {
  /// - Parameters:
  ///   - replacing: Flag to differentiate if should be a push or a set stack
  ///   - navigationController: Navigation controller on which will be pushed or stack should be set
  ///   - animated: Animate the transition
  public init(
    replacing: Bool,
    on navigationController: UINavigationController,
    animated: Bool = true
  ) {
    self.replacing = replacing
    self.navigationController = navigationController
    self.animated = animated
  }

  /// Flag to differentiate if should be a push or a set stack
  public var replacing: Bool

  /// Navigation controller on which stack should be set
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentTermsAndConditions` action
public struct PresentTermsAndConditionsNavigator: TypedNavigator {
  /// View controller which should be pushed or set in navigation stack
  var viewController: () -> UIViewController

  /// - Parameters:
  ///   - viewController: View controller which should be pushed or set in navigation stack
  public init(_ viewController: @escaping () -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentTermsAndConditions, completion: @escaping () -> Void) {
    if action.replacing {
      action.navigationController.setViewControllers([viewController()], animated: action.animated)
    } else {
      action.navigationController.pushViewController(viewController(), animated: action.animated)
    }

    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}
