import HUD
import Combine
import Foundation
import DependencyInjection

final class AccountDeleteViewModel {
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
