import UIKit
import XXModels
import Navigation
import DependencyInjection

public struct PresentContact: Navigation.Action {
  public var contact: Contact
  public var animated: Bool

  public init(
    contact: Contact,
    animated: Bool = true
  ) {
    self.contact = contact
    self.animated = animated
  }
}

public struct PresentContactNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: (Contact) -> UIViewController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentContact, completion: @escaping () -> Void) {
    let pushAction = Push(screen(action.contact), on: navigationController(), animated: action.animated)
    navigator.perform(pushAction, completion: completion)
  }

  public init(
    screen: @escaping (Contact) -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
