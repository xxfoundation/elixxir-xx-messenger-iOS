import UIKit
import XXModels
import Navigation
import DI

public struct PresentGroupChat: Navigation.Action {
  public var model: GroupInfo
  public var animated: Bool

  public init(
    model: GroupInfo,
    animated: Bool = true
  ) {
    self.model = model
    self.animated = animated
  }
}

public struct PresentGroupChatNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: (GroupInfo) -> UIViewController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentGroupChat, completion: @escaping () -> Void) {
    let pushAction = Push(screen(action.model), on: navigationController(), animated: action.animated)
    navigator.perform(pushAction, completion: completion)
  }

  public init(
    screen: @escaping (GroupInfo) -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
