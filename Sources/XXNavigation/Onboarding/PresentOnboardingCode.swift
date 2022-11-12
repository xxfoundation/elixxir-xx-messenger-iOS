import UIKit
import Navigation
import DI

public struct PresentOnboardingCode: Navigation.Action {
  public var isEmail: Bool
  public var content: String
  public var confirmationId: String
  public var animated: Bool

  public init(
    isEmail: Bool,
    content: String,
    confirmationId: String,
    animated: Bool = true
  ) {
    self.isEmail = isEmail
    self.content = content
    self.confirmationId = confirmationId
    self.animated = animated
  }
}

public struct PresentOnboardingCodeNavigator: TypedNavigator {
  @Dependency var navigator: Navigator
  var screen: (Bool, String, String) -> UIViewController
  var navigationController: () -> UINavigationController

  public func perform(_ action: PresentOnboardingCode, completion: @escaping () -> Void) {
    let controller = screen(action.isEmail, action.content, action.confirmationId)
    let pushAction = Push(controller, on: navigationController(), animated: action.animated)
    navigator.perform(pushAction, completion: completion)
  }

  public init(
    screen: @escaping (Bool, String, String) -> UIViewController,
    navigationController: @escaping () -> UINavigationController
  ) {
    self.screen = screen
    self.navigationController = navigationController
  }
}
