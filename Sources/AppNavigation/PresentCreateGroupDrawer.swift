import UIKit
import XXModels

/// Opens up `CreateGroup` on a given parent view controller
public struct PresentCreateGroup: Action {
  /// - Parameters:
  ///   - members: Collection of contacts that will be in the group
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    members: [Contact],
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.members = members
    self.parent = parent
    self.animated = animated
  }

  /// Collection of contacts that will be in the group
  public var members: [Contact]

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentCreateGroup` action
public struct PresentCreateGroupNavigator: TypedNavigator {
  /// Custom transitioning delegate
  let transitioningDelegate = BottomTransitioningDelegate()

  /// View controller which should be opened up
  var viewController: ([Contact]) -> UIViewController

  /// - Parameters:
  ///   - viewController: view controller which should be presented
  public init(_ viewController: @escaping ([Contact]) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentCreateGroup, completion: @escaping () -> Void) {
    transitioningDelegate.isDismissableOnBackgroundTouch = true
    let controller = viewController(action.members)
    controller.transitioningDelegate = transitioningDelegate
    controller.modalPresentationStyle = .overFullScreen

    action.parent.present(
      controller,
      animated: action.animated,
      completion: completion
    )
  }
}
