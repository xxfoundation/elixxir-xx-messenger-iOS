import XCTestDynamicOverlay

public struct HUDShow {
  init(run: @escaping (HUDModel?) -> Void) {
    self.run = run
  }

  public var run: (HUDModel?) -> Void

  public func callAsFunction(_ model: HUDModel? = nil) -> Void {
    run(model)
  }
}

extension HUDShow {
  public static let unimplemented = HUDShow(
    run: XCTUnimplemented("\(Self.self)")
  )
}
