import HUD
import UIKit
import Shared
import Combine
import Defaults
import Permissions
import Integration
import PushNotifications
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
    @Dependency private var session: SessionType
    @Dependency private var pushHandler: PushHandling
    @Dependency private var permissions: PermissionHandling

    @KeyObject(.openedSettingsFirstTime, defaultValue: true) var isFirstTime: Bool
    @KeyObject(.dummyTrafficOn, defaultValue: false) var isDummyTrafficOn: Bool
    @KeyObject(.biometrics, defaultValue: false) private var biometrics
    @KeyObject(.hideAppList, defaultValue: false) private var hideAppList
    @KeyObject(.icognitoKeyboard, defaultValue: false) private var icognitoKeyboard
    @KeyObject(.pushNotifications, defaultValue: false) private var pushNotifications
    @KeyObject(.inappnotifications, defaultValue: true) private var inAppNotifications

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var infoPopupPublisher: AnyPublisher<Void, Never> {
        infoPopupSubject.eraseToAnyPublisher()
    }

    private let infoPopupSubject = PassthroughSubject<Void, Never>()

    var state: AnyPublisher<SettingsViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<SettingsViewState, Never>(.init())

    func loadCachedSettings() {
        stateRelay.value.isHideActiveApps = hideAppList
        stateRelay.value.isBiometricsEnabled = biometrics
        stateRelay.value.isIcognitoKeyboard = icognitoKeyboard
        stateRelay.value.isPushNotification = pushNotifications
        stateRelay.value.isInAppNotification = inAppNotifications
        stateRelay.value.isBiometricsPossible = permissions.isBiometricsAvailable
        stateRelay.value.isDummyTrafficOn = isDummyTrafficOn
    }

    func didAppear() {
        guard isFirstTime else { return }
        isFirstTime = false
        infoPopupSubject.send()
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
        isDummyTrafficOn.toggle()
        stateRelay.value.isDummyTrafficOn = isDummyTrafficOn
        session.setDummyTraffic(status: isDummyTrafficOn)
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
            pushHandler.didRequestAuthorization { [weak self] result in
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
                    try self.session.unregisterNotifications()
                    self.hudRelay.send(.none)
                } catch {
                    self.hudRelay.send(.error(.init(with: error)))
                }

                self.pushNotifications = false
                self.stateRelay.value.isPushNotification = false
            }
        }
    }
}

/*

 - case .appCancel:  The app canceled authentication by invalidating the LAContext
 - case .authenticationFailed: The user did not provide valid credentials
 - case .invalidContext: The LAContext was invalid
 - case .notInteractive: Interaction was not allowed so the authentication failed
 - case .passcodeNotSet: The user has not set a passcode on this device
 - case .systemCancel: The system canceled authentication for example to show another app
 - case .userCancel: The user canceled the authentication dialog
 - case .userFallback: The user selected to use a fallback authentication method
 - case .biometryLockout: Too many failed attempts locked biometric authentication
 - case .biometryNotAvailable: The user's device does not support biometric authentication
 - case .biometryNotEnrolled: The user has not configured biometric authentication

 */
