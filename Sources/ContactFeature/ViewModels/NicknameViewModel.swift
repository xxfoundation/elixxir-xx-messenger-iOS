import Shared
import Combine
import InputField

struct NicknameViewState {
    var nickname: String = ""
    var status: InputField.ValidationStatus = .unknown(nil)
}

final class NicknameViewModel {
    // MARK: Properties

    var state: AnyPublisher<NicknameViewState, Never> {
        stateRelay.eraseToAnyPublisher()
    }

    var done: AnyPublisher<String, Never> {
        doneRelay.eraseToAnyPublisher()
    }

    private let doneRelay = PassthroughSubject<String, Never>()
    private let stateRelay = CurrentValueSubject<NicknameViewState, Never>(.init())

    // MARK: Public

    func didInput(_ string: String) {
        stateRelay.value.nickname = string
        validate()
    }

    func didTapSave() {
        doneRelay.send(stateRelay.value.nickname.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    // MARK: Private

    private func validate() {
        if stateRelay.value.nickname.trimmingCharacters(in: .whitespacesAndNewlines).count >= 1 {
            stateRelay.value.status = .valid(nil)
        } else {
            stateRelay.value.status = .invalid(Localized.Contact.Nickname.minimum)
        }
    }
}
