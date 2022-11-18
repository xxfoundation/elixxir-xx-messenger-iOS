import UIKit

/// Sets or Pushes `Search` on a given navigation controller
public struct PresentSearch: Action {
  /// - Parameters:
  ///   - searching: Optional string to be searched upon further viewModel intialization
  ///   - replacing: Flag to differentiate if should be a push or a set stack
  ///   - navigationController: Navigation controller on which will be pushed or stack should be set
  ///   - animated: Animate the transition
  public init(
    searching: String?,
    replacing: Bool,
    on navigationController: UINavigationController,
    animated: Bool = true
  ) {
    self.searching = searching
    self.replacing = replacing
    self.navigationController = navigationController
    self.animated = animated
  }

  /// Optional string to be searched upon further viewModel intialization
  public var searching: String?

  /// Flag to differentiate if should be a push or a set stack
  public var replacing: Bool

  /// Navigation controller on which stack should be set
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentSearch` action
public struct PresentSearchNavigator: TypedNavigator {
  /// View controller which should be pushed or set in navigation stack
  var viewController: (String?) -> UIViewController

  /// - Parameters:
  ///   - viewController: View controller which should be pushed or set in navigation stack
  public init(_ viewController: @escaping (String?) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentSearch, completion: @escaping () -> Void) {
    if action.replacing {
      action.navigationController.setViewControllers([viewController(action.searching)], animated: action.animated)
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
