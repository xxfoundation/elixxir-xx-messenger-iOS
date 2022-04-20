import HUD
import Combine
import Integration
import Foundation
import DependencyInjection

final class AccountDeleteViewModel {
    @Dependency private var session: SessionType

    var deleting = false

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    func didTapDelete() {
        guard deleting == false else { return }
        deleting = true

        DispatchQueue.main.async { [weak self] in
            self?.hudRelay.send(.on(nil))
        }

        do {
            try session.deleteMyself()
            DependencyInjection.Container.shared.unregister(SessionType.self)

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
