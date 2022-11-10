import Navigation
import Foundation

public struct PresentWebsite: Navigation.Action {
  public var url: URL
  public var animated: Bool

  public init(
    url: URL,
    animated: Bool = true
  ) {
    self.url = url
    self.animated = animated
  }
}
