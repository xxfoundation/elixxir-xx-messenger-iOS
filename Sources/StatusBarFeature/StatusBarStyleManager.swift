import UIKit
import Combine
import XCTestDynamicOverlay

public struct StatusBarStyleManager {
  public var update: StatusBarStyleUpdate
  public var current: StatusBarStyleFetch
  public var observe: StatusBarStyleObserve
}

extension StatusBarStyleManager {
  public static func live() -> StatusBarStyleManager {
    class Context {
      let styleSubject = CurrentValueSubject<UIStatusBarStyle, Never>(.lightContent)
    }

    let context = Context()

    return .init(
      update: .init {
        context.styleSubject.send($0)
      },
      current: .init {
        context.styleSubject.value
      },
      observe: .init {
        context.styleSubject.eraseToAnyPublisher()
      }
    )
  }
}

extension StatusBarStyleManager {
  public static let unimplemented = StatusBarStyleManager(
    update: .unimplemented,
    current: .unimplemented,
    observe: .unimplemented
  )
}
