import HUD
import Combine
import Defaults
import Foundation
import XXClient
import XXMessengerClient
import DependencyInjection
import Models

final class AccountDeleteViewModel {
    @Dependency var messenger: Messenger

    @KeyObject(.username, defaultValue: nil) var username: String?

    var deleting = false

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    func didTapDelete() {
        guard deleting == false else { return }
        deleting = true

        DispatchQueue.main.async { [weak self] in
            self?.hudRelay.send(.on)
        }

        do {
            let fact = Fact(fact: username!, type: FactType.username.rawValue)
            try messenger.ud.get()!.permanentDeleteAccount(username: fact)
            try messenger.destroy()

            DispatchQueue.main.async { [weak self] in
                self?.hudRelay.send(.error(.init(
                    content: "Now kill the app and re-open",
                    title: "Account deleted",
                    dismissable: false
                )))
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.hudRelay.send(.error(.init(with: error)))
            }
        }
    }
}
