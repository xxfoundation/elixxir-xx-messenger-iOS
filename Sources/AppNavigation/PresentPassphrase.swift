public struct PresentPassphrase: Action {
  public var onCancel: () -> Void
  public var onPasspharse: (String) -> Void
  public var animated: Bool

  public init(
    onCancel: @escaping () -> Void,
    onPassphrase: @escaping (String) -> Void,
    animated: Bool = true
  ) {
    self.onCancel = onCancel
    self.onPasspharse = onPassphrase
    self.animated = animated
  }
}
