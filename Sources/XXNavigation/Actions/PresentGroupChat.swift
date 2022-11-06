import XXModels
import Navigation

public struct PresentGroupChat: Navigation.Action {
  public var model: GroupInfo
  public var animated: Bool = true

  public init(model: GroupInfo, animated: Bool = true) {
    self.model = model
    self.animated = animated
  }
}
