import XCTestDynamicOverlay

public struct NetworkMonitorStart {
  public init(run: @escaping () -> Void) {
    self.run = run
  }

  public var run: () -> Void

  public func callAsFunction() -> Void {
    run()
  }
}

extension NetworkMonitorStart {
  public static let unimplemented = NetworkMonitorStart(
    run: XCTUnimplemented("\(Self.self)")
  )
}

