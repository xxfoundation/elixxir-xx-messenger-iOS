import UIKit
import XXModels
import Navigation
import DI

public struct PresentActivitySheet: Navigation.Action {
  public var items: [Any]
  public var animated: Bool

  public init(
    items: [Any],
    animated: Bool = true
  ) {
    self.items = items
    self.animated = animated
  }
}

public struct PresentActivitySheetNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: ([Any]) -> UIViewController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentActivitySheet, completion: @escaping () -> Void) {
    if let topViewController = navigationController().topViewController {
      let modalAction = PresentModal(
        screen(action.items),
        from: topViewController,
        animated: action.animated
      )
      navigator.perform(modalAction, completion: completion)
    }
  }

  public init(
    screen: @escaping ([Any]) -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
