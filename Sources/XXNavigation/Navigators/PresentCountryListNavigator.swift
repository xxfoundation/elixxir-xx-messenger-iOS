import UIKit
import Navigation
import DependencyInjection

public struct PresentCountryListNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: () -> UIViewController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentCountryList, completion: @escaping () -> Void) {
    if let topViewController = navigationController().topViewController {
      let modalAction = PresentModal(screen(), from: topViewController)
    }
  }

  public init(
    screen: @escaping () -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
