import Models
import Shared
import Combine
import XXClient
import Foundation
import InputField
import CombineSchedulers
import XXMessengerClient
import DependencyInjection

struct ProfileEmailViewState: Equatable {
  var input: String = ""
  var confirmation: AttributeConfirmation? = nil
  var status: InputField.ValidationStatus = .unknown(nil)
}

final class ProfileEmailViewModel {
  @Dependency var messenger: Messenger
  @Dependency var hudController: HUDController

  var state: AnyPublisher<ProfileEmailViewState, Never> { stateRelay.eraseToAnyPublisher() }
  private let stateRelay = CurrentValueSubject<ProfileEmailViewState, Never>(.init())

  var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

  func didInput(_ string: String) {
    stateRelay.value.input = string
    validate()
  }

  func clearUp() {
    stateRelay.value.confirmation = nil
  }

  func didTapNext() {
    hudController.show()

    backgroundScheduler.schedule { [weak self] in
      guard let self = self else { return }

      do {
        let confirmationId = try self.messenger.ud.get()!.sendRegisterFact(
          .init(type: .email, value: self.stateRelay.value.input)
        )

        self.hudController.dismiss()
        self.stateRelay.value.confirmation = .init(
          content: self.stateRelay.value.input,
          isEmail: true,
          confirmationId: confirmationId
        )
      } catch {
        let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
        self.hudController.show(.init(content: xxError))
      }
    }
  }

  private func validate() {
    switch Validator.email.validate(stateRelay.value.input) {
    case .success:
      stateRelay.value.status = .valid(nil)
    case .failure(let error):
      stateRelay.value.status = .invalid(error)
    }
  }
}
