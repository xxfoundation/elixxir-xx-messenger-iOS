import XCTestDynamicOverlay

public struct ToastDismiss {
  init(run: @escaping () -> Void) {
    self.run = run
  }

  public var run: () -> Void

  public func callAsFunction() -> Void {
    run()
  }
}

extension ToastDismiss {
  public static let unimplemented = ToastDismiss(
    run: XCTUnimplemented("\(Self.self)")
  )
}
