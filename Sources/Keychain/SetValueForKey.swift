import KeychainAccess
import XCTestDynamicOverlay

public struct SetValueForKey {
  public var run: (String, String) throws -> Void

  public func callAsFunction(_ value: String, for key: String) throws -> Void {
    try run(value, key)
  }
}

extension SetValueForKey {
  public static let live = SetValueForKey { value, key in
    try Keychain(service: "XXM").set(value, key: key)
  }
}

extension SetValueForKey {
  public static let unimplemented = SetValueForKey(
    run: XCTUnimplemented("\(Self.self)")
  )
}
