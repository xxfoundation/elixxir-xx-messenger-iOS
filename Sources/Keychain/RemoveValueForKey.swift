import KeychainAccess
import XCTestDynamicOverlay

public struct RemoveValueForKey {
  public var run: (String) throws -> Void

  public func callAsFunction(_ key: String) throws -> Void {
    try run(key)
  }
}

extension RemoveValueForKey {
  public static let live = RemoveValueForKey {
    try Keychain(service: "XXM").remove($0)
  }
}

extension RemoveValueForKey {
  public static let unimplemented = RemoveValueForKey(
    run: XCTUnimplemented("\(Self.self)")
  )
}
