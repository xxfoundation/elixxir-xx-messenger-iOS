import UIKit
import XXModels

/// Pushes `GroupChat` on a given navigation controller
public struct PresentGroupChat: Action {
  /// - Parameters:
  ///   - groupInfo: Model to build the view controller which will be pushed
  ///   - navigationController: Navigation controller on which push should happen
  ///   - animated: Animate the transition
  public init(
    groupInfo: GroupInfo,
    on navigationController: UINavigationController,
    animated: Bool = true
  ) {
    self.groupInfo = groupInfo
    self.navigationController = navigationController
    self.animated = animated
  }

  /// Model to build the view controller which will be pushed
  public var groupInfo: GroupInfo

  /// Navigation controller on which push should happen
  public var navigationController: UINavigationController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `PresentGroupChat` action
public struct PresentGroupChatNavigator: TypedNavigator {
  /// View controller which should be pushed
  var viewController: (GroupInfo) -> UIViewController

  /// - Parameters:
  ///   - viewController: View controller which should be pushed
  public init(_ viewController: @escaping (GroupInfo) -> UIViewController) {
    self.viewController = viewController
  }

  public func perform(_ action: PresentGroupChat, completion: @escaping () -> Void) {
    action.navigationController.pushViewController(viewController(action.groupInfo), animated: action.animated)
    if action.animated, let coordinator = action.navigationController.transitionCoordinator {
      coordinator.animate(alongsideTransition: nil, completion: { _ in completion() })
    } else {
      completion()
    }
  }
}
