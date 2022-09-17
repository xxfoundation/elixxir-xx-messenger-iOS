import Shared
import Combine
import InputField

struct CreateDrawerViewState {
    var welcome: String?
    var groupName: String = ""
    var status: InputField.ValidationStatus = .unknown(nil)
}

final class CreateDrawerViewModel {
    var statePublisher: AnyPublisher<CreateDrawerViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var donePublisher: AnyPublisher<(String, String?), Never> {
        doneSubject.eraseToAnyPublisher()
    }

    private let doneSubject = PassthroughSubject<(String, String?), Never>()
    private let stateSubject = CurrentValueSubject<CreateDrawerViewState, Never>(.init())

    func didInput(_ string: String) {
        stateSubject.value.groupName = string
        validate()
    }

    func didOtherInput(_ string: String) {
        stateSubject.value.welcome = string
    }

    func didTapCreate() {
        let name = stateSubject.value.groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        let welcome = stateSubject.value.welcome
        doneSubject.send((name, welcome))
    }

    private func validate() {
        let value = stateSubject.value.groupName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard value.count >= 4 else {
            stateSubject.value.status = .invalid(Localized.CreateGroup.Drawer.minimum)
            return
        }

        guard value.count < 21 else {
            stateSubject.value.status = .invalid(Localized.CreateGroup.Drawer.maximum)
            return
        }

        stateSubject.value.status = .valid(nil)
    }
}
