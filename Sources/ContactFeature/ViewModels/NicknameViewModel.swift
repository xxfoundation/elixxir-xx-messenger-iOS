import Combine
import InputField
import AppResources

final class NicknameViewModel {
  struct ViewState: Equatable {
    var input: String
    var status: InputField.ValidationStatus
  }

  var statePublisher: AnyPublisher<ViewState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  private let stateSubject: CurrentValueSubject<ViewState, Never>

  init(prefilled: String) {
    self.stateSubject = .init(.init(
      input: prefilled,
      status: .valid(nil)
    ))
  }

  func getInput() -> String {
    stateSubject.value.input
  }

  func didInput(_ string: String) {
    let input = string.trimmingCharacters(in: .whitespacesAndNewlines)

    stateSubject.value.input = input
    stateSubject.value.status = input.count >= 1 ?
      .valid(nil) :
      .invalid(Localized.Contact.Nickname.minimum)
  }
}
