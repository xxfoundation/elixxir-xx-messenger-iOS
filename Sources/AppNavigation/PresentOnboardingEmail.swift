import UIKit

/// Sets `OnboardingEmail` on a given navigation controller stack
public struct PresentOnboardingEmail: Action {
  /// - Parameters:
  ///   - navigationController: Navigation controller on which stack should be set
  ///   - animated: Animate the transition
  public init(
    on navigationController: UINavigationController,
    animated: Bool = true
  ) {
    self.navigationController = navigationController
    self.animated = animated
  }

  /// Navigation controller on which stack should be set
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentOnboardingEmail` action
public struct PresentOnboardingEmailNavigator: TypedNavigator {
  /// View controller which should be set in navigation stack
  var viewController: () -> UIViewController

  /// - Parameters:
  ///   - viewController: View controller which should be set in navigation stack
  public init(_ viewController: @escaping () -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentOnboardingEmail, completion: @escaping () -> Void) {
    action.navigationController.setViewControllers([viewController()], animated: action.animated)
    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}