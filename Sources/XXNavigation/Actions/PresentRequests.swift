import Navigation

public struct PresentRequests: Navigation.Action {
  public var animated: Bool = true

  public init(animated: Bool = true) {
    self.animated = animated
  }
}
