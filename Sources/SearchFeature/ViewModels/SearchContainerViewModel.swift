import UIKit
import Combine
import Defaults
import XXClient
import PushFeature
import DependencyInjection

final class SearchContainerViewModel {
    @Dependency var pushHandler: PushHandling
    @Dependency var dummyTrafficManager: DummyTraffic

    @KeyObject(.dummyTrafficOn, defaultValue: false) var dummyTrafficOn
    @KeyObject(.pushNotifications, defaultValue: false) var pushNotifications
    @KeyObject(.askedDummyTrafficOnce, defaultValue: false) var offeredCoverTraffic

    var coverTrafficPublisher: AnyPublisher<Void, Never> {
        coverTrafficSubject.eraseToAnyPublisher()
    }

    private let coverTrafficSubject = PassthroughSubject<Void, Never>()

    func didAppear() {
        verifyCoverTraffic()
        verifyNotifications()
    }

    func didEnableCoverTraffic() {
        try! dummyTrafficManager.setStatus(true)
        dummyTrafficOn = true
    }

    private func verifyCoverTraffic() {
        guard offeredCoverTraffic == false else { return }
        offeredCoverTraffic = true
        coverTrafficSubject.send()
    }

    private func verifyNotifications() {
        guard pushNotifications == false else { return }

        pushHandler.requestAuthorization { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let granted):
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }

                self.pushNotifications = granted
            case .failure:
                self.pushNotifications = false
            }
        }
    }
}
