import UIKit

/// Open left view controller on provided parent view controller
public struct OpenLeft: Action {
  /// - Parameters:
  ///   - viewController: View controller to present
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    _ viewController: UIViewController,
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.viewController = viewController
    self.parent = parent
    self.animated = animated
  }

  /// View controller to present
  public var viewController: UIViewController

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `OpenLeft` action
public struct OpenLeftNavigator: TypedNavigator {
  let transitioningDelegate = LeftTransitioningDelegate()

  public init() {}

  public func perform(_ action: OpenLeft, completion: @escaping () -> Void) {
    action.viewController.transitioningDelegate = transitioningDelegate
    action.viewController.modalPresentationStyle = .overFullScreen

    action.parent.present(
      action.viewController,
      animated: action.animated,
      completion: completion
    )
  }
}
