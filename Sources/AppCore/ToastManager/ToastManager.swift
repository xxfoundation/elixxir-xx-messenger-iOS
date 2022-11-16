import Combine
import XCTestDynamicOverlay

public struct ToastManager {
  public var enqueue: ToastEnqueue
  public var dismiss: ToastDismiss
  public var observe: ToastObserve
}

extension ToastManager {
  public static func live() -> ToastManager {
    class Context {
      let queue = CurrentValueSubject<[ToastModel], Never>([])
    }

    let context = Context()

    return .init(
      enqueue: .init {
        context.queue.value.append($0)
      },
      dismiss: .init {
        guard context.queue.value.isEmpty == false else {
          return
        }
        _ = context.queue.value.removeFirst()
      },
      observe: .init {
        context.queue
          .compactMap(\.first)
          .removeDuplicates(by: { $0.id == $1.id })
          .eraseToAnyPublisher()
      }
    )
  }
}

extension ToastManager {
  public static let unimplemented: ToastManager = .init(
    enqueue: .unimplemented,
    dismiss: .unimplemented,
    observe: .unimplemented
  )
}
