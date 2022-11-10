import Shared
import Combine
import Defaults
import XXClient
import InputField
import Foundation
import CombineSchedulers
import XXMessengerClient
import DependencyInjection

final class OnboardingCodeViewModel {
  struct ViewState: Equatable {
    var input: String = ""
    var status: InputField.ValidationStatus = .unknown(nil)
    var resendDebouncer: Int = 0
    var didConfirm: Bool = false
  }

  var statePublisher: AnyPublisher<ViewState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  @Dependency var messenger: Messenger
  @Dependency var hudController: HUDController
  @KeyObject(.email, defaultValue: nil) var email: String?
  @KeyObject(.phone, defaultValue: nil) var phone: String?

  private var timer: Timer?
  private let isEmail: Bool
  private let content: String
  private let confirmationId: String
  private let stateSubject = CurrentValueSubject<ViewState, Never>(.init())
  private var scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

  init(
    isEmail: Bool,
    content: String,
    confirmationId: String
  ) {
    self.isEmail = isEmail
    self.content = content
    self.confirmationId = confirmationId
    didTapResend()
  }

  func didInput(_ string: String) {
    stateSubject.value.input = string
    validate()
  }

  func didTapResend() {
    guard stateSubject.value.resendDebouncer == 0 else { return }
    stateSubject.value.resendDebouncer = 60
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {  [weak self] in
      guard let self, self.stateSubject.value.resendDebouncer > 0 else {
        $0.invalidate()
        return
      }
      self.stateSubject.value.resendDebouncer -= 1
    }
  }

  func didTapNext() {
    hudController.show()
    scheduler.schedule { [weak self] in
      guard let self else { return }
      do {
        try self.messenger.ud.get()!.confirmFact(
          confirmationId: self.confirmationId,
          code: self.stateSubject.value.input
        )
        if self.isEmail {
          self.email = self.content
        } else {
          self.phone = self.content
        }
        self.timer?.invalidate()
        self.hudController.dismiss()
        self.stateSubject.value.didConfirm = true
      } catch {
        self.hudController.dismiss()
        let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
        self.stateSubject.value.status = .invalid(xxError)
      }
    }
  }

  private func validate() {
    switch Validator.code.validate(stateSubject.value.input) {
    case .success:
      stateSubject.value.status = .valid(nil)
    case .failure(let error):
      stateSubject.value.status = .invalid(error)
    }
  }
}
