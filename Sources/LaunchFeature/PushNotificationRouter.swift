import Foundation
import XCTestDynamicOverlay

public struct PushNotificationRouter {
  public typealias NavigateTo = (Route, @escaping () -> Void) -> Void

  public enum Route {
    case requests
    case groupChat(id: Data)
    case contactChat(id: Data)
    case search(username: String)
  }

  public var navigateTo: NavigateTo

  public init(navigateTo: @escaping NavigateTo) {
    self.navigateTo = navigateTo
  }
}

public extension PushNotificationRouter {
  static let unimplemented = PushNotificationRouter(
    navigateTo: XCTUnimplemented("\(Self.self)")
  )
}
