import XCTestDynamicOverlay

public struct NetworkMonitorConnType {
  public init(run: @escaping () -> NetworkMonitorManager.ConnType) {
    self.run = run
  }

  public var run: () -> NetworkMonitorManager.ConnType

  public func callAsFunction() -> NetworkMonitorManager.ConnType {
    run()
  }
}

extension NetworkMonitorConnType {
  public static let unimplemented = NetworkMonitorConnType(
    run: XCTUnimplemented("\(Self.self)")
  )
}
