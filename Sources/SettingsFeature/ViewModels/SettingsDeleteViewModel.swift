import AppCore
import Defaults
import Keychain
import Foundation
import Dependencies
import XXMessengerClient

final class SettingsDeleteViewModel {
  @Dependency(\.keychain) var keychain: KeychainManager
  @Dependency(\.app.dbManager) var dbManager: DBManager
  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.hudManager) var hudManager: HUDManager
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
      try deleteDatabase()
      
      UserDefaults.resetStandardUserDefaults()
      UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
      UserDefaults.standard.synchronize()
      
      hudManager.show(.init(
        title: "Account deleted",
        content: "Now kill the app and re-open"
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
  
  private func deleteDatabase() throws {
    let dbPath = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: "group.elixxir.messenger")!
      .appendingPathComponent("xxm_database")
      .appendingPathExtension("sqlite").path
    
    try FileManager.default.removeItem(atPath: dbPath)
  }
}
