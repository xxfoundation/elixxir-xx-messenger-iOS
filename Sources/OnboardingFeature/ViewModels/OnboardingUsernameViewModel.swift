import AppCore
import Shared
import Combine
import Defaults
import XXModels
import XXClient
import InputField
import Foundation
import XXMessengerClient
import ComposableArchitecture

final class OnboardingUsernameViewModel {
  struct ViewState: Equatable {
    var input: String = ""
    var status: InputField.ValidationStatus = .unknown(nil)
    var didConfirm: Bool = false
  }

  @Dependency(\.app.dbManager) var dbManager: DBManager
  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.hudManager) var hudManager: HUDManager
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  @KeyObject(.username, defaultValue: "") var username: String

  var statePublisher: AnyPublisher<ViewState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  private let stateSubject = CurrentValueSubject<ViewState, Never>(.init())

  func didInput(_ string: String) {
    stateSubject.value.input = string.trimmingCharacters(in: .whitespacesAndNewlines)
    switch Validator.username.validate(stateSubject.value.input) {
    case .success(let text):
      stateSubject.value.status = .valid(text)
    case .failure(let error):
      stateSubject.value.status = .invalid(error)
    }
  }

  func didTapRegister() {
    hudManager.show()
    bgQueue.schedule { [weak self] in
      guard let self else { return }
      do {
        try self.messenger.register(
          username: self.stateSubject.value.input
        )
        try self.dbManager.getDB().saveContact(.init(
          id: self.messenger.e2e.get()!.getContact().getId(),
          marshaled: self.messenger.e2e.get()!.getContact().data,
          username: self.stateSubject.value.input,
          email: nil,
          phone: nil,
          nickname: nil,
          photo: nil,
          authStatus: .friend,
          isRecent: false,
          isBlocked: false,
          isBanned: false,
          createdAt: Date()
        ))
        self.username = self.stateSubject.value.input
        self.hudManager.hide()
        self.stateSubject.value.didConfirm = true
      } catch {
        self.hudManager.hide()
        let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
        self.stateSubject.value.status = .invalid(xxError)
      }
    }
  }
}
