import XCTestDynamicOverlay

public struct HUDHide {
  init(run: @escaping () -> Void) {
    self.run = run
  }

  public var run: () -> Void

  public func callAsFunction() -> Void {
    run()
  }
}

extension HUDHide {
  public static let unimplemented = HUDHide(
    run: XCTUnimplemented("\(Self.self)")
  )
}
