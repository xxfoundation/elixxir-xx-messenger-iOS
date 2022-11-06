import Navigation

public struct PresentTermsAndConditions: Navigation.Action {
  public var animated: Bool = true
  public var popAllowed: Bool = true

  public init(
    animated: Bool = true,
    popAllowed: Bool = true
  ) {
    self.animated = animated
    self.popAllowed = popAllowed
  }
}
