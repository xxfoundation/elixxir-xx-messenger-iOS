import XCTestDynamicOverlay

public struct NetworkMonitorUpdate {
  public init(run: @escaping (Bool) -> Void) {
    self.run = run
  }

  public var run: (Bool) -> Void

  public func callAsFunction(_ status: Bool) -> Void {
    run(status)
  }
}

extension NetworkMonitorUpdate {
  public static let unimplemented = NetworkMonitorUpdate(
    run: XCTUnimplemented("\(Self.self)")
  )
}
