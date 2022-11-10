import Navigation

public struct PresentCamera: Navigation.Action {
  public var animated: Bool

  public init(animated: Bool = true) {
    self.animated = animated
  }
}
