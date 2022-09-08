import HUD
import Models
import Combine
import Defaults
import Keychain
import XXClient
import Foundation
import XXMessengerClient
import DependencyInjection
import Retry
import XXModels

final class AccountDeleteViewModel {
    @Dependency var messenger: Messenger
    @Dependency var keychain: KeychainHandling
    @Dependency var database: Database

    @KeyObject(.username, defaultValue: nil) var username: String?

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    private var isCurrentlyDeleting = false
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)

    func didTapDelete() {
        guard isCurrentlyDeleting == false else { return }
        isCurrentlyDeleting = true

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hudSubject.send(.on)
        }

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            do {
                print(">>> try self.cleanUD()")
                try self.cleanUD()

                print(">>> try self.messenger.destroy()")
                try self.messenger.destroy()

                print(">>> try self.keychain.clear()")
                try self.keychain.clear()

                print(">>> try database.drop()")
                try self.database.drop()

                print(">>> try self.deleteDatabase()")

                try self.deleteDatabase()

                UserDefaults.resetStandardUserDefaults()
                UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                UserDefaults.standard.synchronize()

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.hudSubject.send(.error(.init(
                        content: "Now kill the app and re-open",
                        title: "Account deleted",
                        dismissable: false
                    )))
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.hudSubject.send(.error(.init(with: error)))
                }
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
