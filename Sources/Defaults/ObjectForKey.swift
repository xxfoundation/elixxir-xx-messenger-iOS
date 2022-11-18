import Foundation
import XCTestDynamicOverlay

public struct ObjectForKey {
  public var run: (String) -> Any?

  public func callAsFunction(_ key: String) -> Any? {
    run(key)
  }
}

extension ObjectForKey {
  public static let live = ObjectForKey {
    UserDefaults.standard.object(forKey: $0)
  }
}

extension ObjectForKey {
  public static let unimplemented = ObjectForKey(
    run: XCTUnimplemented("\(Self.self)")
  )
}
