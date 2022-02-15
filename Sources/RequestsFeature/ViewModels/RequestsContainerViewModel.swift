import HUD
import Combine

final class RequestsContainerViewModel {
    // MARK: Properties

    var hud: AnyPublisher<HUDStatus, Never> {
        hudRelay.eraseToAnyPublisher()
    }

    private let hudRelay = PassthroughSubject<HUDStatus, Never>()

    // MARK: Public

    func didReceive(hud: HUDStatus) {
        hudRelay.send(hud)
    }
}
