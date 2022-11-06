import Navigation

public struct PresentOnboardingWelcome: Navigation.Action {
  public var animated: Bool = true

  public init(animated: Bool = true) {
    self.animated = animated
  }
}
