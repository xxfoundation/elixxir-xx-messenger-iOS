import UIKit

/// Pushes `OnboardingCode` on a given navigation controller
public struct PresentOnboardingCode: Action {
  /// - Parameters:
  ///   - isEmail: Flag to differentiate email or phone code
  ///   - content: Content that is being set if confirmation code gets validated
  ///   - confirmationId: Confirmation id to validate with third-party
  ///   - navigationController: Navigation controller on which push should happen
  ///   - animated: Animate the transition
  public init(
    isEmail: Bool,
    content: String,
    confirmationId: String,
    on navigationController: UINavigationController,
    animated: Bool = true
  ) {
    self.isEmail = isEmail
    self.content = content
    self.confirmationId = confirmationId
    self.navigationController = navigationController
    self.animated = animated
  }

  /// Flag to differentiate email or phone code
  public var isEmail: Bool

  /// Content that is being set if confirmation code gets validated
  public var content: String

  /// Confirmation id to validate with third-party
  public var confirmationId: String

  /// Navigation controller on which push should happen
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentOnboardingCode` action
public struct PresentOnboardingCodeNavigator: TypedNavigator {
  /// View controller which should be pushed
  var viewController: (Bool, String, String) -> UIViewController

  /// - Parameters:
  ///   - viewController: View controller which should be pushed
  public init(_ viewController: @escaping (Bool, String, String) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentOnboardingCode, completion: @escaping () -> Void) {
    let controller = viewController(action.isEmail, action.content, action.confirmationId)
    action.navigationController.pushViewController(controller, animated: action.animated)
    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}
