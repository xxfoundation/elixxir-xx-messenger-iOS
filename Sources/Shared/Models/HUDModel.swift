import UIKit

public struct HUDModel {
  var title: String?
  var content: String?
  var actionTitle: String?
  var isDismissable: Bool
  var animationColor: UIColor?
  var onTapClosure: (() -> Void)?

  public init(
    title: String? = nil,
    content: String? = nil,
    actionTitle: String? = nil,
    isDismissable: Bool = true,
    animationColor: UIColor? = nil,
    onTapClosure: (() -> Void)? = nil
  ) {
    self.title = title
    self.content = content
    self.actionTitle = actionTitle
    self.isDismissable = isDismissable
    self.onTapClosure = onTapClosure
    self.animationColor = animationColor
  }

  public init(
    error: Error,
    isDismissable: Bool = true
  ) {
    self.isDismissable = isDismissable
    self.title = Localized.Hud.Error.title
    self.content = error.localizedDescription
    self.actionTitle = Localized.Hud.Error.action
  }
}

//public struct HUDError: Equatable {
//  var title: String
//  var content: String
//  var buttonTitle: String
//  var dismissable: Bool
//
//  public init(
//    content: String,
//    title: String = Localized.Hud.Error.title,
//    buttonTitle: String = Localized.Hud.Error.action,
//    dismissable: Bool = true
//  ) {
//    self.title = title
//    self.content = content
//    self.buttonTitle = buttonTitle
//    self.dismissable = dismissable
//  }
//
//  public init(with error: Error) {
//    self.title = Localized.Hud.Error.title
//    self.buttonTitle = Localized.Hud.Error.action
//    self.content = error.localizedDescription
//    self.dismissable = true
//  }
//}
