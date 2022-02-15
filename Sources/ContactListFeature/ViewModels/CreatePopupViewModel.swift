import Shared
import Combine
import InputField

struct CreatePopupViewState {
    var welcome: String?
    var groupName: String = ""
    var status: InputField.ValidationStatus = .unknown(nil)
}

final class CreatePopupViewModel {
    // MARK: Properties

    var state: AnyPublisher<CreatePopupViewState, Never> {
        stateRelay.eraseToAnyPublisher()
    }

    var done: AnyPublisher<(String, String?), Never> {
        doneRelay.eraseToAnyPublisher()
    }

    private let doneRelay = PassthroughSubject<(String, String?), Never>()
    private let stateRelay = CurrentValueSubject<CreatePopupViewState, Never>(.init())

    // MARK: Public

    func didInput(_ string: String) {
        stateRelay.value.groupName = string
        validate()
    }

    func didOtherInput(_ string: String) {
        stateRelay.value.welcome = string
    }

    func didTapCreate() {
        let name = stateRelay.value.groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        let welcome = stateRelay.value.welcome
        doneRelay.send((name, welcome))
    }

    // MARK: Private

    private func validate() {
        let value = stateRelay.value.groupName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard value.count > 4 else {
            stateRelay.value.status = .invalid(Localized.CreateGroup.Popup.minimum)
            return
        }

        guard value.count < 32 else {
            stateRelay.value.status = .invalid(Localized.CreateGroup.Popup.maximum)
            return
        }

        stateRelay.value.status = .valid(nil)
    }
}
