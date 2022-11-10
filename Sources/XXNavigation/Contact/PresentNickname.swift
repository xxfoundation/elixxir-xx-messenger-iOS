import Navigation

public struct PresentNickname: Navigation.Action {
  public var prefilled: String?
  public var completion: (String) -> Void
  public var animated: Bool

  public init(
    prefilled: String?,
    completion: @escaping (String) -> Void,
    animated: Bool = true
  ) {
    self.prefilled = prefilled
    self.completion = completion
    self.animated = animated
  }
}
