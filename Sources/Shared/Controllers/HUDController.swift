import Combine

public final class HUDController {
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

    modelSubject.send(model)
  }
}
