import UIKit
import Shared
import Navigation
import DI

public struct PresentMenu: Navigation.Action {
  public var currentItem: MenuItem
  public var animated: Bool

  public init(
    currentItem: MenuItem,
    animated: Bool = true
  ) {
    self.currentItem = currentItem
    self.animated = animated
  }
}

public struct PresentMenuNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var navigationController: () -> UINavigationController
  var screen: (MenuItem) -> UIViewController

  public func perform(_ action: PresentMenu, completion: @escaping () -> Void) {
    if let topViewController = navigationController().topViewController {
      let openLeftAction = OpenLeft(
        screen(action.currentItem),
        from: topViewController,
        animated: action.animated
      )
      navigator.perform(openLeftAction, completion: completion)
    }
  }

  public init(
    screen: @escaping (MenuItem) -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
