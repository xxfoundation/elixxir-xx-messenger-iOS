import UIKit
import XXModels

/// Pushes `Contact` on a given navigation controller
public struct PresentContact: Action {
  /// - Parameters:
  ///   - contact: Model to build the view controller which will be pushed
  ///   - navigationController: Navigation controller on which push should happen
  ///   - animated: Animate the transition
  public init(
    contact: Contact,
    on navigationController: UINavigationController,
    animated: Bool = true
  ) {
    self.contact = contact
    self.navigationController = navigationController
    self.animated = animated
  }

  /// Model to build the view controller which will be opened up
  public var contact: Contact

  /// Navigation controller on which push should happen
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentContact` action
public struct PresentContactNavigator: TypedNavigator {
  /// View controller which should be pushed
  var viewController: (Contact) -> UIViewController

  /// - Parameters:
  ///   - viewController: View controller which should be pushed
  public init(_ viewController: @escaping (Contact) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentContact, completion: @escaping () -> Void) {
    action.navigationController.pushViewController(viewController(action.contact), animated: action.animated)
    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}
