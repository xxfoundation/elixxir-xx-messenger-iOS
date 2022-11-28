import Foundation
import XCTestDynamicOverlay

public struct SetObjectForKey {
  public var run: (Any?, String) -> Void

  public func callAsFunction(_ value: Any?, for key: String) -> Void {
    run(value, key)
  }
}

extension SetObjectForKey {
  public static let live = SetObjectForKey { value, key in
    UserDefaults.standard.set(value, forKey: key)
  }
}

extension SetObjectForKey {
  public static let unimplemented = SetObjectForKey(
    run: XCTUnimplemented("\(Self.self)")
  )
}
