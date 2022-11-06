import UIKit
import XXModels
import Navigation
import DependencyInjection

public struct PresentChatNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: (Contact) -> UIViewController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentChat, completion: @escaping () -> Void) {
    let pushAction = Push(screen(action.contact), on: navigationController(), animated: action.animated)
    navigator.perform(pushAction, completion: completion)
  }

  public init(
    screen: @escaping (Contact) -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
