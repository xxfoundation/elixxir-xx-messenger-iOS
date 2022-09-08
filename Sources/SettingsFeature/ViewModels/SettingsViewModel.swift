import HUD
import UIKit
import Shared
import Combine
import Defaults
import Permissions
import PushFeature
import XXClient
import XXMessengerClient
import UserNotifications
import CombineSchedulers
import DependencyInjection

struct SettingsViewState: Equatable {
    var isHideActiveApps: Bool = false
    var isPushNotification: Bool = false
    var isIcognitoKeyboard: Bool = false
    var isInAppNotification: Bool = false
    var isBiometricsEnabled: Bool = false
    var isBiometricsPossible: Bool = false
    var isDummyTrafficOn = false
}

final class SettingsViewModel {
    @Dependency var messenger: Messenger
    @Dependency var pushHandler: PushHandling
    @Dependency var permissions: PermissionHandling
    @Dependency var dummyTrafficManager: DummyTraffic

    @KeyObject(.biometrics, defaultValue: false) var biometrics
    @KeyObject(.hideAppList, defaultValue: false) var hideAppList
    @KeyObject(.dummyTrafficOn, defaultValue: false) var dummyTrafficOn
    @KeyObject(.icognitoKeyboard, defaultValue: false) var icognitoKeyboard
    @KeyObject(.pushNotifications, defaultValue: false) var pushNotifications
    @KeyObject(.inappnotifications, defaultValue: true) var inAppNotifications

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var state: AnyPublisher<SettingsViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<SettingsViewState, Never>(.init())

    func loadCachedSettings() {
        stateRelay.value.isHideActiveApps = hideAppList
        stateRelay.value.isBiometricsEnabled = biometrics
        stateRelay.value.isIcognitoKeyboard = icognitoKeyboard
        stateRelay.value.isPushNotification = pushNotifications
        stateRelay.value.isInAppNotification = inAppNotifications
        stateRelay.value.isBiometricsPossible = permissions.isBiometricsAvailable
        stateRelay.value.isDummyTrafficOn = dummyTrafficManager.getStatus()
    }

    func didToggleBiometrics() {
        biometricAuthentication(enable: !biometrics)
    }

    func didToggleInAppNotifications() {
        inAppNotifications.toggle()
        stateRelay.value.isInAppNotification.toggle()
    }

    func didTogglePushNotifications() {
        pushNotifications(enable: !pushNotifications)
    }

    func didToggleDummyTraffic() {
        let currently = dummyTrafficManager.getStatus()
        try! dummyTrafficManager.setStatus(!currently)
        stateRelay.value.isDummyTrafficOn = !currently
        dummyTrafficOn = stateRelay.value.isDummyTrafficOn
    }

    func didToggleHideActiveApps() {
        hideAppList.toggle()
        stateRelay.value.isHideActiveApps.toggle()
    }

    func didToggleIcognitoKeyboard() {
        icognitoKeyboard.toggle()
        stateRelay.value.isIcognitoKeyboard.toggle()
    }

    // MARK: Private

    private func biometricAuthentication(enable: Bool) {
        stateRelay.value.isBiometricsEnabled = enable

        guard enable == true else {
            biometrics = false
            stateRelay.value.isBiometricsEnabled = false
            return
        }

        permissions.requestBiometrics { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let granted):
                if granted {
                    self.biometrics = true
                    self.stateRelay.value.isBiometricsEnabled = true
                } else {
                    self.biometrics = false
                    self.stateRelay.value.isBiometricsEnabled = false
                }
            case .failure:
                self.biometrics = false
                self.stateRelay.value.isBiometricsEnabled = false
            }
        }
    }

    private func pushNotifications(enable: Bool) {
        hudRelay.send(.on)

        if enable == true {
            pushHandler.requestAuthorization { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let granted):
                    self.pushNotifications = granted
                    self.stateRelay.value.isPushNotification = granted
                    if granted { DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }}
                    self.hudRelay.send(.none)

                case .failure(let error):
                    self.hudRelay.send(.error(.init(with: error)))
                    self.pushNotifications = false
                    self.stateRelay.value.isPushNotification = false
                }
            }
        } else {
            backgroundScheduler.schedule { [weak self] in
                guard let self = self else { return }

                do {
                    try UnregisterForNotifications.live(
                        e2eId: self.messenger.e2e.get()!.getId()
                    )

                    self.hudRelay.send(.none)
                } catch {
                    let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
                    self.hudRelay.send(.error(.init(content: xxError)))
                }

                self.pushNotifications = false
                self.stateRelay.value.isPushNotification = false
            }
        }
    }
}
