import UIKit
import XCTestDynamicOverlay

public struct StatusBarStyleFetch {
  public var run: () -> UIStatusBarStyle

  public func callAsFunction() -> UIStatusBarStyle {
    run()
  }
}

extension StatusBarStyleFetch {
  public static let unimplemented = StatusBarStyleFetch(
    run: XCTUnimplemented("\(Self.self)")
  )
}
