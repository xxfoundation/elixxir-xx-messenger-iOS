import Navigation

public struct PresentOnboardingCode: Navigation.Action {
  public var isEmail: Bool
  public var content: String
  public var animated: Bool = true
  public var confirmationId: String

  public init(
    isEmail: Bool,
    content: String,
    confirmationId: String,
    animated: Bool = true
  ) {
    self.animated = animated
    self.isEmail = isEmail
    self.content = content
    self.confirmationId = confirmationId
  }
}
