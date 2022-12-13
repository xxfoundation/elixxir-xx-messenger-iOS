import Combine
import Dependencies
import Foundation
import XCTestDynamicOverlay

public struct HUDManager {
  public struct Show {
    public var run: (HUDModel?) -> Void
    public func callAsFunction(_ model: HUDModel? = nil) {
      run(model)
    }
  }

  public var show: Show
  public var hide: () -> Void
  public var observe: () -> AnyPublisher<HUDModel?, Never>
}

extension HUDManager {
  public static func live() -> HUDManager {
    let subject = PassthroughSubject<HUDModel?, Never>()
    @Dependency(\.mainQueue) var mainQueue
    return HUDManager(
      show: .init { model in
        mainQueue.schedule {
          let model = model ?? HUDModel(hasDotAnimation: true)
          subject.send(model)
          if model.isAutoDismissable {
            mainQueue.schedule(after: mainQueue.now.advanced(by: 2)) {
              subject.send(nil)
            }
          }
        }
      },
      hide: {
        mainQueue.schedule {
          subject.send(nil)
        }
      },
      observe: {
        subject.eraseToAnyPublisher()
      }
    )
  }
}

extension HUDManager {
  public static let unimplemented = HUDManager(
    show: .init(run: XCTestDynamicOverlay.unimplemented("\(Self.self).show")),
    hide: XCTestDynamicOverlay.unimplemented("\(Self.self).hide"),
    observe: XCTestDynamicOverlay.unimplemented(
      "\(Self.self).observe",
      placeholder: Empty().eraseToAnyPublisher()
    )
  )
}

private enum HUDManagerKey: DependencyKey {
  static let liveValue: HUDManager = .live()
  static let testValue: HUDManager = .unimplemented
}

extension DependencyValues {
  public var hudManager: HUDManager {
    get { self[HUDManagerKey.self] }
    set { self[HUDManagerKey.self] = newValue }
  }
}
