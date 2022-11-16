import XCTestDynamicOverlay

public struct NetworkMonitorStatus {
  public init(run: @escaping () -> NetworkMonitorManager.Status) {
    self.run = run
  }

  public var run: () -> NetworkMonitorManager.Status

  public func callAsFunction() -> NetworkMonitorManager.Status {
    run()
  }
}

extension NetworkMonitorStatus {
  public static let unimplemented = NetworkMonitorStatus(
    run: XCTUnimplemented("\(Self.self)")
  )
}
