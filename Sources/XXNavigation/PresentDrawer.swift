import UIKit
import Navigation
import DrawerFeature
import DI

public struct PresentDrawer: Navigation.Action {
  public var items: [DrawerItem]
  public var dismissable: Bool
  public var animated: Bool

  public init(
    items: [DrawerItem],
    dismissable: Bool = true,
    animated: Bool = true
  ) {
    self.items = items
    self.dismissable = dismissable
    self.animated = animated
  }
}

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
