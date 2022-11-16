import XCTestDynamicOverlay

public struct ToastEnqueue {
  init(run: @escaping (ToastModel) -> Void) {
    self.run = run
  }

  public var run: (ToastModel) -> Void

  public func callAsFunction(_ model: ToastModel) -> Void {
    run(model)
  }
}

extension ToastEnqueue {
  public static let unimplemented = ToastEnqueue(
    run: XCTUnimplemented("\(Self.self)")
  )
}
