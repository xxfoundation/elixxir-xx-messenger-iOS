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
    modelSubject.send(model)
  }
}
