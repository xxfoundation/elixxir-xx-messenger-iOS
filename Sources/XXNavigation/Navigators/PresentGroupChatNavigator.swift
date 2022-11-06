import UIKit
import XXModels
import Navigation
import DependencyInjection

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
