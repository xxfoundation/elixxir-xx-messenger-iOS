import UIKit
import AppCore
import Combine
import XXClient
import Defaults
import XXMessengerClient
import PermissionsFeature
import ComposableArchitecture

final class SettingsMainViewModel {
  struct ViewState: Equatable {
    var isHideActiveApps: Bool = false
    var isPushNotification: Bool = false
    var isIcognitoKeyboard: Bool = false
    var isInAppNotification: Bool = false
    var isBiometricsEnabled: Bool = false
    var isBiometricsPossible: Bool = false
    var isDummyTrafficOn = false
  }

  @Dependency(\.app.bgQueue) var bgQueue
  @Dependency(\.permissions) var permissions
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.dummyTraffic) var dummyTraffic
  @Dependency(\.hudManager) var hudManager

  @KeyObject(.biometrics, defaultValue: false) var biometrics
  @KeyObject(.hideAppList, defaultValue: false) var hideAppList
  @KeyObject(.dummyTrafficOn, defaultValue: false) var dummyTrafficOn
  @KeyObject(.icognitoKeyboard, defaultValue: false) var icognitoKeyboard
  @KeyObject(.pushNotifications, defaultValue: false) var pushNotifications
  @KeyObject(.inappnotifications, defaultValue: true) var inAppNotifications

  var statePublisher: AnyPublisher<ViewState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  private let stateSubject = CurrentValueSubject<ViewState, Never>(.init())

  func loadCachedSettings() {
    stateSubject.value.isHideActiveApps = hideAppList
    stateSubject.value.isBiometricsEnabled = biometrics
    stateSubject.value.isIcognitoKeyboard = icognitoKeyboard
    stateSubject.value.isPushNotification = pushNotifications
    stateSubject.value.isInAppNotification = inAppNotifications
    stateSubject.value.isBiometricsPossible = permissions.biometrics.status()
    stateSubject.value.isDummyTrafficOn = dummyTraffic.get()!.getStatus()
  }
  
  func didToggleBiometrics() {
    biometricAuthentication(enable: !biometrics)
  }
  
  func didToggleInAppNotifications() {
    inAppNotifications.toggle()
    stateSubject.value.isInAppNotification.toggle()
  }
  
  func didTogglePushNotifications() {
    pushNotifications(enable: !pushNotifications)
  }
  
  func didToggleDummyTraffic() {
    let currently = dummyTraffic.get()!.getStatus()
    try! dummyTraffic.get()!.setStatus(!currently)
    stateSubject.value.isDummyTrafficOn = !currently
    dummyTrafficOn = stateSubject.value.isDummyTrafficOn
  }

  func didToggleHideActiveApps() {
    hideAppList.toggle()
    stateSubject.value.isHideActiveApps.toggle()
  }

  func didToggleIcognitoKeyboard() {
    icognitoKeyboard.toggle()
    stateSubject.value.isIcognitoKeyboard.toggle()
  }

  private func biometricAuthentication(enable: Bool) {
    stateSubject.value.isBiometricsEnabled = enable

    guard enable == true else {
      biometrics = false
      stateSubject.value.isBiometricsEnabled = false
      return
    }

    permissions.biometrics.request { [weak self] in
      guard let self else { return }
      self.biometrics = $0
      self.stateSubject.value.isBiometricsEnabled = $0
    }
  }
  
  private func pushNotifications(enable: Bool) {
    hudManager.show()

    if enable == true {
      permissions.push.request { [weak self] granted in
        guard let self else { return }
        self.pushNotifications = granted
        self.stateSubject.value.isPushNotification = granted
        if granted {
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
        }
        self.hudManager.hide()
      }
    } else {
      bgQueue.schedule { [weak self] in
        guard let self else { return }
        do {
          try UnregisterForNotifications.live(
            e2eId: self.messenger.e2e.get()!.getId()
          )
          self.hudManager.hide()
        } catch {
          let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
          self.hudManager.show(.init(content: xxError))
        }
        self.pushNotifications = false
        self.stateSubject.value.isPushNotification = false
      }
    }
  }
}
