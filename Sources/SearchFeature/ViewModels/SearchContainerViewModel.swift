import UIKit
import Combine
import Defaults
import Integration
import PushFeature
import DependencyInjection

final class SearchContainerViewModel {
    @Dependency var session: SessionType
    @Dependency var pushHandler: PushHandling

    @KeyObject(.dummyTrafficOn, defaultValue: false) var isCoverTrafficEnabled
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
        isCoverTrafficEnabled = true
        session.setDummyTraffic(status: true)
    }

    private func verifyCoverTraffic() {
        guard offeredCoverTraffic == false else { return }
        offeredCoverTraffic = true
        coverTrafficSubject.send()
    }

    private func verifyNotifications() {
        guard pushNotifications == false else { return }

        pushHandler.requestAuthorization { [weak self] result in
            guard let self = self else { return }

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
