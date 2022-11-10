import UIKit
import Navigation
import DependencyInjection

public struct PresentSettingsBackup: Navigation.Action {
  public var animated: Bool

  public init(animated: Bool = true) {
    self.animated = animated
  }
}

public struct PresentSettingsBackupNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: () -> UIViewController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentSettingsBackup, completion: @escaping () -> Void) {
    let pushAction = Push(screen(), on: navigationController(), animated: action.animated)
    navigator.perform(pushAction, completion: completion)
  }

  public init(
    screen: @escaping () -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
