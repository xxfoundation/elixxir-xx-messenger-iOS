import XCTestDynamicOverlay

public struct StartNetworkMonitor {
  public init(run: @escaping () -> Void) {
    self.run = run
  }

  public var run: () -> Void

  public func callAsFunction() -> Void {
    run()
  }
}

extension StartNetworkMonitor {
  public static let unimplemented = StartNetworkMonitor(
    run: XCTUnimplemented("\(Self.self)")
  )
}

