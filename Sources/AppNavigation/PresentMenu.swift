import UIKit

/// Options that can be lead to a flow on the menu UI
public enum MenuItem {
  case join
  case scan
  case chats
  case share
  case profile
  case contacts
  case requests
  case settings
  case dashboard
}

/// Opens left `Menu` on a given parent view controller
public struct PresentMenu: Action {
  /// - Parameters:
  ///   - currentItem: A correlation with the flow that this controller is being presented
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    currentItem: MenuItem,
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.currentItem = currentItem
    self.parent = parent
    self.animated = animated
  }

  /// A correlation with the flow that this controller is being presented
  public var currentItem: MenuItem

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentMenu` action
public struct PresentMenuNavigator: TypedNavigator {
  /// Custom transitioning delegate
  let transitioningDelegate = LeftTransitioningDelegate()

  /// View controller which should be opened left
  var viewController: (MenuItem, UINavigationController?) -> UIViewController

  /// - Parameters:
  ///   - viewController: view controller which should be presented
  public init(_ viewController: @escaping (MenuItem, UINavigationController?) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentMenu, completion: @escaping () -> Void) {
    let controller = viewController(action.currentItem, action.parent.navigationController)
    controller.transitioningDelegate = transitioningDelegate
    controller.modalPresentationStyle = .overFullScreen
    action.parent.present(
      controller,
      animated: action.animated,
      completion: completion
    )
  }
}
