import AppCore
import Shared
import Combine
import XXClient
import InputField
import Foundation
import CombineSchedulers
import XXMessengerClient
import CountryListFeature
import ComposableArchitecture

final class OnboardingPhoneViewModel {
  struct ViewState: Equatable {
    var input: String = ""
    var content: String?
    var confirmationId: String?
    var status: InputField.ValidationStatus = .unknown(nil)
    var country: Country = .fromMyPhone()
  }

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.hudManager) var hudManager: HUDManager
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

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

  func didChooseCountry(_ country: Country) {
    stateSubject.value.country = country
    validate()
  }

  func didTapNext() {
    hudManager.show()
    bgQueue.schedule { [weak self] in
      guard let self else { return }
      let content = "\(self.stateSubject.value.input)\(self.stateSubject.value.country.code)"
      do {
        let confirmationId = try self.messenger.ud.get()!.sendRegisterFact(
          .init(type: .phone, value: content)
        )
        self.hudManager.hide()
        self.stateSubject.value.content = content
        self.stateSubject.value.confirmationId = confirmationId
      } catch {
        self.hudManager.hide()
        let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
        self.stateSubject.value.status = .invalid(xxError)
      }
    }
  }

  private func validate() {
    switch Validator.phone.validate((stateSubject.value.country.regex, stateSubject.value.input)) {
    case .success:
      stateSubject.value.status = .valid(nil)
    case .failure(let error):
      stateSubject.value.status = .invalid(error)
    }
  }
}
