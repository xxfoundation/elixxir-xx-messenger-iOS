import Combine
import XCTestDynamicOverlay

public struct ToastObserve {
  public var run: () -> AnyPublisher<ToastModel, Never>

  public func callAsFunction() -> AnyPublisher<ToastModel, Never> {
    run()
  }
}

extension ToastObserve {
  public static let unimplemented = ToastObserve(
    run: XCTUnimplemented("\(Self.self)")
  )
}
