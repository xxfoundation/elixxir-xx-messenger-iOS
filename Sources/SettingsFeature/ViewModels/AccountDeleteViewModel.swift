import Shared
import Retry
import Combine
import Defaults
import Keychain
import XXModels
import XXClient
import Foundation
import XXMessengerClient
import DependencyInjection

final class AccountDeleteViewModel {
  @Dependency var database: Database
  @Dependency var messenger: Messenger
  @Dependency var keychain: KeychainHandling
  @Dependency var hudController: HUDController
  
  @KeyObject(.username, defaultValue: nil) var username: String?

  private var isCurrentlyDeleting = false
  
  func didTapDelete() {
    guard isCurrentlyDeleting == false else { return }
    isCurrentlyDeleting = true

    hudController.show()
    
    do {
      print(">>> try self.cleanUD()")
      try cleanUD()
      
      print(">>> try self.messenger.destroy()")
      try messenger.destroy()
      
      print(">>> try self.keychain.clear()")
      try keychain.clear()
      
      print(">>> try database.drop()")
      try database.drop()
      
      print(">>> try self.deleteDatabase()")
      try deleteDatabase()
      
      UserDefaults.resetStandardUserDefaults()
      UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
      UserDefaults.standard.synchronize()
      
      hudController.show(.init(
        title: "Account deleted",
        content: "Now kill the app and re-open"
      ))
    } catch {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.hudController.show(.init(error: error))
      }
    }
  }
  
  private func cleanUD() throws {
    print(">>> Deleting my username (\(username ?? "NO_USERNAME")) from ud")
    try messenger.ud.get()!.permanentDeleteAccount(username: .init(type: .username, value: username!))
  }
  
  private func deleteDatabase() throws {
    print(">>> Deleting database...")
    
    let dbPath = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: "group.elixxir.messenger")!
      .appendingPathComponent("xxm_database")
      .appendingPathExtension("sqlite").path
    
    try FileManager.default.removeItem(atPath: dbPath)
  }
}
