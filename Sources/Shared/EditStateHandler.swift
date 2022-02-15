import Combine

public final class EditStateHandler {
    // MARK: Properties

    public var isEditing: AnyPublisher<Bool, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<Bool, Never>(false)

    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public func didSwitchEditing() {
        stateRelay.value.toggle()
    }
}
