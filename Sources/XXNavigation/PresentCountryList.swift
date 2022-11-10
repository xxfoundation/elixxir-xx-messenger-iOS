import UIKit
import Shared
import Navigation
import DependencyInjection

public struct PresentCountryList: Navigation.Action {
  public var completion: ((Country) -> Void)
  public var animated: Bool

  public init(
    completion: @escaping (Country) -> Void,
    animated: Bool = true
  ) {
    self.animated = animated
    self.completion = completion
  }
}

public struct PresentCountryListNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: (@escaping (Country) -> Void) -> UIViewController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentCountryList, completion: @escaping () -> Void) {
    if let topViewController = navigationController().topViewController {
      let modalAction = PresentModal(screen(action.completion), from: topViewController)
      navigator.perform(modalAction, completion: completion)
    }
  }

  public init(
    screen: @escaping (@escaping (Country) -> Void) -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
