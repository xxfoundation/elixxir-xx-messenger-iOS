import Foundation
import XCTestDynamicOverlay

public struct FetchLocalVersion {
  public var run: () -> String?

  public func callAsFunction() -> String? {
    run()
  }
}

extension FetchLocalVersion {
  public static let live = FetchLocalVersion {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
  }
}

extension FetchLocalVersion {
  public static let unimplemented = FetchLocalVersion(
    run: XCTUnimplemented("\(Self.self)")
  )
}
