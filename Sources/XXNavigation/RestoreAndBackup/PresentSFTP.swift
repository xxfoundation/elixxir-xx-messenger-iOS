import Navigation

public struct PresentSFTP: Navigation.Action {
  public var completion: (String, String, String) -> Void
  public var animated: Bool

  public init(
    completion: @escaping (String, String, String) -> Void,
    animated: Bool = true
  ) {
    self.completion = completion
    self.animated = animated
  }
}
