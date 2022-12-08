import Shared
import Combine
import AppCore
import Defaults
import XXClient
import InputField
import Foundation
import XXMessengerClient
import ComposableArchitecture

final class ProfileCodeViewModel {
  struct ViewState: Equatable {
    var input: String = ""
    var status: InputField.ValidationStatus = .unknown(nil)
    var resendDebouncer: Int = 0
    var didConfirm: Bool = false
  }

  var statePublisher: AnyPublisher<ViewState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  @Dependency(\.app.bgQueue) var bgQueue
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.hudManager) var hudManager

  @KeyObject(.email, defaultValue: nil) var email: String?
  @KeyObject(.phone, defaultValue: nil) var phone: String?

  private var timer: Timer?
  private let isEmail: Bool
  private let content: String
  private var confirmationId: String
  private let stateSubject = CurrentValueSubject<ViewState, Never>(.init())

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
    bgQueue.schedule { [weak self] in
      guard let self else { return }
      do {
        self.confirmationId = try self.messenger.ud.tryGet()
          .sendRegisterFact(.init(
            type: self.isEmail ? .email : .phone,
            value: self.content
          ))
      } catch {
        self.hudManager.show(.init(error: error))
      }
    }
  }

  func didTapNext() {
    hudManager.show()
    bgQueue.schedule { [weak self] in
      guard let self else { return }
      do {
        try self.messenger.ud.tryGet().confirmFact(
          confirmationId: self.confirmationId,
          code: self.stateSubject.value.input
        )
        if self.isEmail {
          self.email = self.content
        } else {
          self.phone = self.content
        }
        self.timer?.invalidate()
        self.hudManager.hide()
        self.stateSubject.value.didConfirm = true
      } catch {
        let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
        self.hudManager.show(.init(content: xxError))
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
