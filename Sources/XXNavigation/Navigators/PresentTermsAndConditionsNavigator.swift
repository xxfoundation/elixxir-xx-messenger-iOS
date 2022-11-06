import UIKit
import Navigation
import DependencyInjection

public struct PresentTermsAndConditionsNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: () -> UIViewController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentTermsAndConditions, completion: @escaping () -> Void) {
    let navAction: Action
    if action.popAllowed {
      navAction = Push(screen(), on: navigationController(), animated: action.animated)
    } else {
      navAction = SetStack([screen()], on: navigationController(), animated: action.animated)
    }
    navigator.perform(navAction, completion: completion)
  }

  public init(
    screen: @escaping () -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
