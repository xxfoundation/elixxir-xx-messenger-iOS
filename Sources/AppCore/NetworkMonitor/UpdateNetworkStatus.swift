import XCTestDynamicOverlay

public struct UpdateNetworkStatus {
  public init(run: @escaping (Bool) -> Void) {
    self.run = run
  }

  public var run: (Bool) -> Void

  public func callAsFunction(_ status: Bool) -> Void {
    run(status)
  }
}

extension UpdateNetworkStatus {
  public static let unimplemented = UpdateNetworkStatus(
    run: XCTUnimplemented("\(Self.self)")
  )
}
