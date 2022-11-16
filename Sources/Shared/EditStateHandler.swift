import Combine

public final class EditStateHandler {
  public var isEditing: AnyPublisher<Bool, Never> { stateRelay.eraseToAnyPublisher() }
  private let stateRelay = CurrentValueSubject<Bool, Never>(false)

  public init() {}

  public func didSwitchEditing() {
    stateRelay.value.toggle()
  }
}
