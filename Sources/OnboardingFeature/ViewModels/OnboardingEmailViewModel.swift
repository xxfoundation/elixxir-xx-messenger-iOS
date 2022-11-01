import UIKit
import Models
import Shared
import Combine
import Defaults
import XXClient
import InputField
import CombineSchedulers
import XXMessengerClient
import DependencyInjection

struct OnboardingEmailViewState: Equatable {
  var input: String = ""
  var confirmation: AttributeConfirmation? = nil
  var status: InputField.ValidationStatus = .unknown(nil)
}

final class OnboardingEmailViewModel {
  @Dependency var messenger: Messenger
  @Dependency var hudController: HUDController
  
  @KeyObject(.pushNotifications, defaultValue: false) private var pushNotifications
  
  var state: AnyPublisher<OnboardingEmailViewState, Never> { stateRelay.eraseToAnyPublisher() }
  private let stateRelay = CurrentValueSubject<OnboardingEmailViewState, Never>(.init())
  
  var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()
  
  func clearUp() {
    stateRelay.value.confirmation = nil
  }
  
  func didInput(_ string: String) {
    stateRelay.value.input = string
    validate()
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
