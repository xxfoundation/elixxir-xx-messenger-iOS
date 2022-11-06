import UIKit
import Navigation
import DependencyInjection

public struct PresentSearchNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: (String?) -> UIViewController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentSearch, completion: @escaping () -> Void) {
    let setStackAction = SetStack([screen(action.searching)], on: navigationController(), animated: action.animated)
    navigator.perform(setStackAction, completion: completion)
  }

  public init(
    screen: @escaping (String?) -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
