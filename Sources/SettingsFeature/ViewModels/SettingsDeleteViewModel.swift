import AppCore
import Defaults
import Keychain
import Foundation
import Dependencies
import AppResources
import XXMessengerClient

final class SettingsDeleteViewModel {
  @Dependency(\.keychain) var keychain
  @Dependency(\.app.dbManager) var dbManager
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.app.hudManager) var hudManager
  @KeyObject(.username, defaultValue: nil) var username: String?

  private var isCurrentlyDeleting = false
  
  func didTapDelete() {
    guard isCurrentlyDeleting == false else { return }
    isCurrentlyDeleting = true

    hudManager.show()
    
    do {
      try cleanUD()
      try messenger.destroy()
      try keychain.destroy()
      try dbManager.removeDB()

      UserDefaults.resetStandardUserDefaults()
      UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
      UserDefaults.standard.synchronize()

      hudManager.show(.init(
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
  
  private func cleanUD() throws {
    try messenger.ud.get()!.permanentDeleteAccount(
      username: .init(type: .username, value: username!)
    )
  }
}
