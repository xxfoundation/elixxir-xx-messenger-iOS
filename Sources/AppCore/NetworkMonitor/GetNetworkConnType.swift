import XCTestDynamicOverlay

public struct GetNetworkConnType {
  public init(run: @escaping () -> NetworkMonitor.ConnType) {
    self.run = run
  }

  public var run: () -> NetworkMonitor.ConnType

  public func callAsFunction() -> NetworkMonitor.ConnType {
    run()
  }
}

extension GetNetworkConnType {
  public static let unimplemented = GetNetworkConnType(
    run: XCTUnimplemented("\(Self.self)")
  )
}
