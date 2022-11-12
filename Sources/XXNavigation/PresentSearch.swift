import UIKit
import Navigation
import DI

public struct PresentSearch: Navigation.Action {
  public var searching: String?
  public var replacing: Bool
  public var animated: Bool

  public init(
    searching: String? = nil,
    replacing: Bool = true,
    animated: Bool = true
  ) {
    self.searching = searching
    self.replacing = replacing
    self.animated = animated
  }
}

public struct PresentSearchNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: (String?) -> UIViewController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentSearch, completion: @escaping () -> Void) {
    let navAction: Action
    if action.replacing {
      navAction = SetStack([screen(action.searching)], on: navigationController(), animated: action.animated)
    } else {
      navAction = Push(screen(action.searching), on: navigationController(), animated: action.animated)
    }
    navigator.perform(navAction, completion: completion)
  }

  public init(
    screen: @escaping (String?) -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
