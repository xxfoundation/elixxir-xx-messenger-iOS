import Foundation
import XCTestDynamicOverlay

public struct RemoveObjectForKey {
  public var run: (String) -> Void

  public func callAsFunction(_ key: String) -> Void {
    run(key)
  }
}

extension RemoveObjectForKey {
  public static let live = RemoveObjectForKey {
    UserDefaults.standard.removeObject(forKey: $0)
  }
}

extension RemoveObjectForKey {
  public static let unimplemented = RemoveObjectForKey(
    run: XCTUnimplemented("\(Self.self)")
  )
}
