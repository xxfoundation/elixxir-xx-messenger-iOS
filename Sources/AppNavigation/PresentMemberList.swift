import XXModels

public struct PresentMemberList: Action {
  public var members: [Contact]
  public var animated: Bool

  public init(
    members: [Contact],
    animated: Bool = true
  ) {
    self.members = members
    self.animated = animated
  }
}
