import Combine
import Foundation

public final class HUDController {
  private var timer: Timer?

  var modelPublisher: AnyPublisher<HUDModel?, Never> {
    modelSubject.eraseToAnyPublisher()
  }

  private let modelSubject = PassthroughSubject<HUDModel?, Never>()

  public init() {}

  public func dismiss() {
    modelSubject.send(nil)
  }

  public func show(_ model: HUDModel? = nil) {
    guard let model else {
      modelSubject.send(.init(hasDotAnimation: true))
      return
    }

    if model.isAutoDismissable {
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
        guard let self else { return }
        self.modelSubject.send(nil)
      }
    }

    modelSubject.send(model)
  }
}
