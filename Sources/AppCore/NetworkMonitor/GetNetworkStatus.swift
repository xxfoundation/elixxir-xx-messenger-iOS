import XCTestDynamicOverlay

public struct GetNetworkStatus {
  public init(run: @escaping () -> NetworkMonitor.Status) {
    self.run = run
  }

  public var run: () -> NetworkMonitor.Status

  public func callAsFunction() -> NetworkMonitor.Status {
    run()
  }
}

extension GetNetworkStatus {
  public static let unimplemented = GetNetworkStatus(
    run: XCTUnimplemented("\(Self.self)")
  )
}
