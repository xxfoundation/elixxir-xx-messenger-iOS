import UIKit
import Combine
import Defaults
import XXClient
import PermissionsFeature
import ComposableArchitecture

final class SearchContainerViewModel {
  @Dependency(\.permissions) var permissions
  //@Dependency(\.app.dummyTraffic) var dummyTraffic: DummyTraffic

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
//    try! dummyTraffic.setStatus(true)
    dummyTrafficOn = true
  }

  private func verifyCoverTraffic() {
    guard offeredCoverTraffic == false else { return }
    offeredCoverTraffic = true
    coverTrafficSubject.send()
  }

  private func verifyNotifications() {
    guard pushNotifications == false else { return }

    permissions.push.request { [weak self] granted in
      guard let self else { return }
      if granted == true {
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
      self.pushNotifications = granted
    }
  }
}
