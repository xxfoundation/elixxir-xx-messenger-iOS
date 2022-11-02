import UIKit

public struct HUDModel {
  var title: String?
  var content: String?
  var actionTitle: String?
  var hasDotAnimation: Bool
  var onTapClosure: (() -> Void)?

  public init(
    title: String? = nil,
    content: String? = nil,
    actionTitle: String? = nil,
    hasDotAnimation: Bool = false,
    onTapClosure: (() -> Void)? = nil
  ) {
    self.title = title
    self.content = content
    self.actionTitle = actionTitle
    self.onTapClosure = onTapClosure
    self.hasDotAnimation = hasDotAnimation
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
    self.content = error.localizedDescription
  }
}
