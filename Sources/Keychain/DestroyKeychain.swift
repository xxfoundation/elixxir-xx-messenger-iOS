import KeychainAccess
import XCTestDynamicOverlay

public struct DestroyKeychain {
  public var run: () throws -> Void

  public func callAsFunction() throws -> Void {
    try run()
  }
}

extension DestroyKeychain {
  public static let live = DestroyKeychain {
    try Keychain(service: "XXM").removeAll()
  }
}

extension DestroyKeychain {
  public static let unimplemented = DestroyKeychain(
    run: XCTUnimplemented("\(Self.self)")
  )
}
