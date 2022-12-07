import AppCore
import Shared
import Combine
import XXClient
import InputField
import Foundation
import CombineSchedulers
import XXMessengerClient
import ComposableArchitecture

final class OnboardingEmailViewModel {
  struct ViewState: Equatable {
    var input: String = ""
    var confirmationId: String?
    var status: InputField.ValidationStatus = .unknown(nil)
  }

  @Dependency(\.app.bgQueue) var bgQueue
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.hudManager) var hudManager

  var statePublisher: AnyPublisher<ViewState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  private let stateSubject = CurrentValueSubject<ViewState, Never>(.init())

  func clearUp() {
    stateSubject.value.confirmationId = nil
  }

  func didInput(_ string: String) {
    stateSubject.value.input = string
    validate()
  }

  func didTapNext() {
    hudManager.show()
    bgQueue.schedule { [weak self] in
      guard let self else { return }
      do {
        let confirmationId = try self.messenger.ud.get()!.sendRegisterFact(
          .init(type: .email, value: self.stateSubject.value.input)
        )
        self.hudManager.hide()
        self.stateSubject.value.confirmationId = confirmationId
      } catch {
        self.hudManager.hide()
        let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
        self.stateSubject.value.status = .invalid(xxError)
      }
    }
  }

  private func validate() {
    switch Validator.email.validate(stateSubject.value.input) {
    case .success:
      stateSubject.value.status = .valid(nil)
    case .failure(let error):
      stateSubject.value.status = .invalid(error)
    }
  }
}
