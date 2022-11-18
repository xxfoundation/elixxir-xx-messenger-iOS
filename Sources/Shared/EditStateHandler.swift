import Combine

public final class EditStateHandler {
  public var isEditing: AnyPublisher<Bool, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  private let stateSubject = CurrentValueSubject<Bool, Never>(false)

  public init() {}

  public func didSwitchEditing() {
    stateSubject.value.toggle()
  }
}
