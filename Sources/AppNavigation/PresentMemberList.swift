import UIKit
import XXModels

/// Opens up `GroupMembers` on a given parent view controller
public struct PresentGroupMembers: Action {
  /// - Parameters:
  ///   - groupInfo: Model that represents the group info that contains the members to be shown
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    groupInfo: GroupInfo,
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.groupInfo = groupInfo
    self.parent = parent
    self.animated = animated
  }

  /// Model that represents the group info that contains the members to be shown
  public var groupInfo: GroupInfo

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentGroupMembers` action
public struct PresentGroupMembersNavigator: TypedNavigator {
  /// Custom transitioning delegate
  let transitioningDelegate = BottomTransitioningDelegate()

  /// View controller which should be opened up
  var viewController: (GroupInfo) -> UIViewController

  /// - Parameters:
  ///   - viewController: view controller which should be presented
  public init(_ viewController: @escaping (GroupInfo) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentGroupMembers, completion: @escaping () -> Void) {
    let controller = viewController(action.groupInfo)
    controller.transitioningDelegate = transitioningDelegate
    controller.modalPresentationStyle = .overFullScreen

    action.parent.present(
      controller,
      animated: action.animated,
      completion: completion
    )
  }
}
