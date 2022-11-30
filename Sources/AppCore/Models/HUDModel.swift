import UIKit
import AppResources

public struct HUDModel {
  var title: String?
  var content: String?
  var actionTitle: String?
  var hasDotAnimation: Bool
  var isAutoDismissable: Bool
  var onTapClosure: (() -> Void)?

  public init(
    title: String? = nil,
    content: String? = nil,
    actionTitle: String? = nil,
    hasDotAnimation: Bool = false,
    isAutoDismissable: Bool = false,
    onTapClosure: (() -> Void)? = nil
  ) {
    self.title = title
    self.content = content
    self.actionTitle = actionTitle
    self.onTapClosure = onTapClosure
    self.hasDotAnimation = hasDotAnimation
    self.isAutoDismissable = isAutoDismissable
  }

  public init(
    error: Error,
    actionTitle: String? = Localized.Hud.Error.action,
    onTapClosure: (() -> Void)? = nil
  ) {
    self.hasDotAnimation = false
    self.actionTitle = actionTitle
    self.onTapClosure = onTapClosure
    self.title = Localized.Hud.Error.title
    self.isAutoDismissable = onTapClosure == nil
    self.content = error.localizedDescription
  }
}