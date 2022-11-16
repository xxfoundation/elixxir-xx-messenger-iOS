import UIKit
import XCTestDynamicOverlay

public struct StatusBarStyleUpdate {
  public var run: (UIStatusBarStyle) -> Void

  public func callAsFunction(_ style: UIStatusBarStyle) -> Void {
    run(style)
  }
}

extension StatusBarStyleUpdate {
  public static let unimplemented = StatusBarStyleUpdate(
    run: XCTUnimplemented("\(Self.self)")
  )
}
