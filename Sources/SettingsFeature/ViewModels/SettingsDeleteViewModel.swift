import AppCore
import Combine
import Defaults
import Keychain
import Foundation
import Dependencies
import AppResources
import XXMessengerClient

final class SettingsDeleteViewModel {
  struct ViewState: Equatable {
    var input = ""
    var username: String
    var isButtonEnabled = false
  }

  @Dependency(\.keychain) var keychain
  @Dependency(\.app.bgQueue) var bgQueue
  @Dependency(\.app.dbManager) var dbManager
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.app.hudManager) var hudManager
  @KeyObject(.username, defaultValue: nil) var username: String?

  var statePublisher: AnyPublisher<ViewState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  private let stateSubject: CurrentValueSubject<ViewState, Never>

  init() {
    @KeyObject(.username, defaultValue: nil) var username: String?
    self.stateSubject = .init(.init(username: username!))
  }

  func didEnterText(_ string: String) {
    stateSubject.value.input = string
    stateSubject.value.isButtonEnabled = string == stateSubject.value.username
  }

  func didTapDelete() {
    hudManager.show()

    bgQueue.schedule { [weak self] in
      guard let self else { return }
      do {
        try self.messenger.ud.tryGet().permanentDeleteAccount(
          username: .init(
            type: .username,
            value: self.stateSubject.value.username
          )
        )
        try self.messenger.destroy()
        try self.keychain.destroy()
        try self.dbManager.removeDB()

        UserDefaults.resetStandardUserDefaults()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()

        self.hudManager.show(.init(
          title: Localized.Settings.Delete.Success.title,
          content: Localized.Settings.Delete.Success.subtitle
        ))
      } catch {
        DispatchQueue.main.async { [weak self] in
          guard let self else { return }
          self.hudManager.show(.init(error: error))
        }
      }
    }
  }
}
