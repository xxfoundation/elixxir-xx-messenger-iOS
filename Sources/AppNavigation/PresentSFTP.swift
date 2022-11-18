import UIKit

/// Pushes `SFTP` on a given navigation controller
public struct PresentSFTP: Action {
  /// - Parameters:
  ///   - completion: Completion closure with host, username and password
  ///   - navigationController: Navigation controller on which push should happen
  ///   - animated: Animate the transition
  public init(
    completion: @escaping (String, String, String) -> Void,
    on navigationController: UINavigationController,
    animated: Bool = true
  ) {
    self.completion = completion
    self.navigationController = navigationController
    self.animated = animated
  }

  /// Completion closure with host, username and password
  public var completion: (String, String, String) -> Void

  /// Navigation controller on which push should happen
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentSFTP` action
public struct PresentSFTPNavigator: TypedNavigator {
  /// View controller which should be pushed
  var viewController: (@escaping (String, String, String) -> Void) -> UIViewController

  /// - Parameters:
  ///   - viewController: View controller which should be pushed
  public init(_ viewController: @escaping (@escaping (String, String, String) -> Void) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentSFTP, completion: @escaping () -> Void) {
    let controller = viewController(action.completion)
    action.navigationController.pushViewController(controller, animated: action.animated)
    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}
