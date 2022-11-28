import UIKit

/// Sets or Pushes `Search` on a given navigation controller
public struct PresentSearch: Action {
  /// - Parameters:
  ///   - searching: Optional string to be searched upon further viewModel intialization
  ///   - fromOnboarding: Flag that differentiates if should be a push or a set stack
  ///   - navigationController: Navigation controller on which will be pushed or stack should be set
  ///   - animated: Animate the transition
  public init(
    searching: String? = nil,
    fromOnboarding: Bool = false,
    on navigationController: UINavigationController,
    animated: Bool = true
  ) {
    self.searching = searching
    self.fromOnboarding = fromOnboarding
    self.navigationController = navigationController
    self.animated = animated
  }

  /// Optional string to be searched upon further viewModel intialization
  public var searching: String?

  /// Flag that differentiates if should be a push or a set stack
  public var fromOnboarding: Bool

  /// Navigation controller on which stack should be set
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentSearch` action
public struct PresentSearchNavigator: TypedNavigator {
  /// View controller which should be pushed or set in navigation stack
  var viewController: (String?) -> UIViewController

  /// View controller which might have to be pushed below in navigation stack
  var otherViewController: () -> UIViewController

  /// - Parameters:
  ///   - viewController: View controller which should be pushed or set in navigation stack
  ///   - otherViewController: View controller which might have to be pushed below in navigation stack
  public init(
    _ otherViewController: @escaping () -> UIViewController,
    _ viewController: @escaping (String?) -> UIViewController
  ) {
    self.viewController = viewController
    self.otherViewController = otherViewController
  }

  public func perform(_ action: PresentSearch, completion: @escaping () -> Void) {
    if action.fromOnboarding {
      action.navigationController.setViewControllers([otherViewController(), viewController(action.searching)], animated: action.animated)
    } else {
      action.navigationController.pushViewController(viewController(action.searching), animated: action.animated)
    }

    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}
