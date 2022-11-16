import Combine
import Foundation
import XCTestDynamicOverlay

public struct HUDManager {
  public var show: HUDShow
  public var hide: HUDHide
  public var observe: HUDObserve
}

extension HUDManager {
  public static func live() -> HUDManager {
    class Context {
      var timer: Timer?
      let modelSubject = PassthroughSubject<HUDModel?, Never>()
    }

    let context = Context()

    return .init(
      show: .init {
        guard let model = $0 else {
          context.modelSubject.send(.init(hasDotAnimation: true))
          return
        }
        if model.isAutoDismissable {
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            context.modelSubject.send(nil)
          }
        }
        context.modelSubject.send(model)
      },
      hide: .init {
        context.modelSubject.send(nil)
      },
      observe: .init {
        context.modelSubject.eraseToAnyPublisher()
      }
    )
  }
}

extension HUDManager {
  public static let unimplemented = HUDManager(
    show: .unimplemented,
    hide: .unimplemented,
    observe: .unimplemented
  )
}
