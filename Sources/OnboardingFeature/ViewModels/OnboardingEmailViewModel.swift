import Shared
import Combine
import XXClient
import InputField
import Foundation
import CombineSchedulers
import XXMessengerClient
import DependencyInjection

final class OnboardingEmailViewModel {
  struct ViewState: Equatable {
    var input: String = ""
    var confirmationId: String?
    var status: InputField.ValidationStatus = .unknown(nil)
  }

  @Dependency var messenger: Messenger
  @Dependency var hudController: HUDController

  var statePublisher: AnyPublisher<ViewState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  private let stateSubject = CurrentValueSubject<ViewState, Never>(.init())
  private var scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

  func clearUp() {
    stateSubject.value.confirmationId = nil
  }

  func didInput(_ string: String) {
    stateSubject.value.input = string
    validate()
  }

  func didTapNext() {
    hudController.show()
    scheduler.schedule { [weak self] in
      guard let self else { return }
      do {
        let confirmationId = try self.messenger.ud.get()!.sendRegisterFact(
          .init(type: .email, value: self.stateSubject.value.input)
        )
        self.hudController.dismiss()
        self.stateSubject.value.confirmationId = confirmationId
      } catch {
        self.hudController.dismiss()
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
