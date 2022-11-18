import KeychainAccess
import XCTestDynamicOverlay

public struct GetValueForKey {
  public var run: (String) throws -> String?

  public func callAsFunction(_ key: String) throws -> String? {
    try run(key)
  }
}

extension GetValueForKey {
  public static let live = GetValueForKey {
    try Keychain(service: "XXM").get($0)
  }
}

extension GetValueForKey {
  public static let unimplemented = GetValueForKey(
    run: XCTUnimplemented("\(Self.self)")
  )
}
