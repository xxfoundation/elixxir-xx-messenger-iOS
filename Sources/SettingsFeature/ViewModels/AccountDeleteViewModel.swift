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

final class AccountDeleteViewModel {
    @Dependency var messenger: Messenger
    @Dependency var keychain: KeychainHandling

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
                try self.cleanUD()
                try self.stopNetwork()
                try self.messenger.destroy()
                try self.keychain.clear()
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
        let fact = Fact(fact: username!, type: FactType.username.rawValue)

        print(">>> Deleting my username (\(fact.fact)) from ud")
        try messenger.ud.get()!.permanentDeleteAccount(username: fact)
    }

    private func stopNetwork() throws {
        let cMix = messenger.cMix.get()!

        print(">>> Stopping network follower...")
        try cMix.stopNetworkFollower()

        retry(max: 10, retryStrategy: .delay(seconds: 2)) {
            if cMix.networkFollowerStatus() != .stopped {
                print(">>> Network still hasn't stopped. Its \(cMix.networkFollowerStatus())")
                throw NSError.create("Gave up on stopping the network.")
            }

            print(">>> Network has stopped")
        }
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
