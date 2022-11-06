import Navigation

public struct PresentSearch: Navigation.Action {
  public var searching: String?
  public var animated: Bool = true

  public init(searching: String? = nil, animated: Bool = true) {
    self.searching = searching
    self.animated = animated
  }
}
