import UIKit

/// Open up view controller on provided parent view controller
public struct OpenUp: Action {
  /// - Parameters:
  ///   - viewController: View controller to present
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  ///   - dismissable: Dismissable upon background touch flag
  public init(
    _ viewController: UIViewController,
    from parent: UIViewController,
    animated: Bool = true,
    dismissable: Bool = true
  ) {
    self.viewController = viewController
    self.parent = parent
    self.animated = animated
    self.dismissable = dismissable
  }

  /// View controller to present
  public var viewController: UIViewController

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool

  /// Dismissable upon background touch flag
  public var dismissable: Bool
}

/// Performs `OpenUp` action
public struct OpenUpNavigator: TypedNavigator {
  let transitioningDelegate = BottomTransitioningDelegate()

  public init() {}

  public func perform(_ action: OpenUp, completion: @escaping () -> Void) {
    transitioningDelegate.isDismissableOnBackgroundTouch = action.dismissable
    action.viewController.transitioningDelegate = transitioningDelegate
    action.viewController.modalPresentationStyle = .overFullScreen

    action.parent.present(
      action.viewController,
      animated: action.animated,
      completion: completion
    )
  }
}
