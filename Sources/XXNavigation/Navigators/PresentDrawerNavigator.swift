import UIKit
import Navigation
import DrawerFeature
import DependencyInjection

public struct PresentDrawerNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: ([DrawerItem]) -> UIViewController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentDrawer, completion: @escaping () -> Void) {
    if let topViewController = navigationController().topViewController {
      let openUpAction = OpenUp(
        screen(action.items),
        from: topViewController,
        animated: action.animated,
        dismissable: action.dismissable
      )
      navigator.perform(openUpAction, completion: completion)
    }
  }

  public init(
    screen: @escaping ([DrawerItem]) -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
