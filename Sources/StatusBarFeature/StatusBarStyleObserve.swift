import UIKit
import Combine
import XCTestDynamicOverlay

public struct StatusBarStyleObserve {
  public var run: () -> AnyPublisher<UIStatusBarStyle, Never>

  public func callAsFunction() -> AnyPublisher<UIStatusBarStyle, Never> {
    run()
  }
}

extension StatusBarStyleObserve {
  public static let unimplemented = StatusBarStyleObserve(
    run: XCTUnimplemented("\(Self.self)")
  )
}
