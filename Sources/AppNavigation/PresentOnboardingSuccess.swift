import UIKit

/// Sets `OnboardingSuccess` on a given navigation controller stack
public struct PresentOnboardingSuccess: Action {
  /// - Parameters:
  ///   - isEmail: Flag to differentiate email from phone number
  ///   - navigationController: Navigation controller on which stack should be set
  ///   - animated: Animate the transition
  public init(
    isEmail: Bool,
    on navigationController: UINavigationController,
    animated: Bool = true
  ) {
    self.isEmail = isEmail
    self.navigationController = navigationController
    self.animated = animated
  }

  /// Flag to differentiate email from phone number
  public var isEmail: Bool

  /// Navigation controller on which stack should be set
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentOnboardingSuccess` action
public struct PresentOnboardingSuccessNavigator: TypedNavigator {
  /// View controller which should be set in navigation stack
  var viewController: (Bool) -> UIViewController

  /// - Parameters:
  ///   - viewController: View controller which should be set in navigation stack
  public init(_ viewController: @escaping (Bool) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentOnboardingSuccess, completion: @escaping () -> Void) {
    let target = viewController(action.isEmail)
    action.navigationController.setViewControllers([target], animated: action.animated)
    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}
