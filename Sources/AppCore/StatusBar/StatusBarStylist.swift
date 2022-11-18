import UIKit
import Combine
import XCTestDynamicOverlay

public struct StatusBarStylist {
  public var set: SetStyle
  public var get: GetStyle
  public var observe: ObserveStyle

  public static func live() -> StatusBarStylist {
    let styleSubject = CurrentValueSubject<UIStatusBarStyle, Never>(.lightContent)
    return .init(
      set: .init { styleSubject.send($0) },
      get: .init { styleSubject.value },
      observe: .init { styleSubject.eraseToAnyPublisher() }
    )
  }
  public static let unimplemented = StatusBarStylist(
    set: .unimplemented,
    get: .unimplemented,
    observe: .unimplemented
  )
}

public struct GetStyle {
  public var run: () -> UIStatusBarStyle

  public func callAsFunction() -> UIStatusBarStyle {
    run()
  }

  public static let unimplemented = GetStyle(
    run: XCTUnimplemented("\(Self.self)")
  )
}

public struct SetStyle {
  public var run: (UIStatusBarStyle) -> Void

  public func callAsFunction(_ style: UIStatusBarStyle) -> Void {
    run(style)
  }

  public static let unimplemented = SetStyle(
    run: XCTUnimplemented("\(Self.self)")
  )
}

public struct ObserveStyle {
  public var run: () -> AnyPublisher<UIStatusBarStyle, Never>

  public func callAsFunction() -> AnyPublisher<UIStatusBarStyle, Never> {
    run()
  }

  public static let unimplemented = ObserveStyle(
    run: XCTUnimplemented("\(Self.self)")
  )
}
