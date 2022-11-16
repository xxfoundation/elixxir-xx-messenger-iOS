import Combine
import XCTestDynamicOverlay

public struct HUDObserve {
  public var run: () -> AnyPublisher<HUDModel?, Never>

  public func callAsFunction() -> AnyPublisher<HUDModel?, Never> {
    run()
  }
}

extension HUDObserve {
  public static let unimplemented = HUDObserve(
    run: XCTUnimplemented("\(Self.self)")
  )
}
