import Shared
import Combine
import AppCore
import XXModels
import Defaults
import XXClient
import Foundation
import AppResources
import ReportingFeature
import XXMessengerClient
import PermissionsFeature
import ComposableArchitecture

enum ScanningStatus: Equatable {
  case reading
  case processing
  case success
  case failed(ScanningError)
}

enum ScanningError: Equatable {
  case requestOpened
  case unknown(String)
  case cameraPermission
  case alreadyFriends(String)
}

final class SearchRightViewModel {
  @Dependency(\.app.dbManager) var dbManager: DBManager
  @Dependency(\.permissions) var permissions: PermissionsManager
  @Dependency(\.reportingStatus) var reportingStatus: ReportingStatus

  var foundPublisher: AnyPublisher<XXModels.Contact, Never> {
    foundSubject.eraseToAnyPublisher()
  }

  var cameraSemaphorePublisher: AnyPublisher<Bool, Never> {
    cameraSemaphoreSubject.eraseToAnyPublisher()
  }

  var statusPublisher: AnyPublisher<ScanningStatus, Never> {
    statusSubject.eraseToAnyPublisher()
  }

  private let foundSubject = PassthroughSubject<XXModels.Contact, Never>()
  private let cameraSemaphoreSubject = PassthroughSubject<Bool, Never>()
  private(set) var statusSubject = CurrentValueSubject<ScanningStatus, Never>(.reading)

  func viewWillAppear() {
    permissions.camera.request { [weak self] granted in
      guard let self else { return }

      if granted {
        self.statusSubject.value = .reading
        self.cameraSemaphoreSubject.send(true)
      } else {
        self.statusSubject.send(.failed(.cameraPermission))
      }
    }
  }

  func viewWillDisappear() {
    cameraSemaphoreSubject.send(false)
  }

  func didScan(data: Data) {
    /// We need to be accepting new readings in order
    /// to process what just got scanned.
    ///
    guard statusSubject.value == .reading else { return }
    statusSubject.send(.processing)

    /// Whatever got scanned, needs to have id and username
    /// otherwise is just noise or an unknown qr code
    ///
    let user = XXClient.Contact.live(data)

    guard
      let uid = try? user.getId(),
      let facts = try? user.getFacts(),
      let username = facts.first(where: { $0.type == .username })?.value
    else {
      let errorTitle = Localized.Scan.Error.invalid
      statusSubject.send(.failed(.unknown(errorTitle)))
      return
    }

    let email = facts.first { $0.type == .email }?.value
    let phone = facts.first { $0.type == .phone }?.value

    /// Make sure we are not processing a contact
    /// that we already have
    ///
    if let alreadyContact = try? dbManager.getDB().fetchContacts(.init(id: [uid])).first {
      if alreadyContact.isBlocked, reportingStatus.isEnabled() {
        statusSubject.send(.failed(.unknown("You previously blocked this user.")))
        return
      }

      if alreadyContact.isBanned, reportingStatus.isEnabled() {
        statusSubject.send(.failed(.unknown("This user was banned.")))
        return
      }

      /// Show error accordingly to the auth status
      ///
      if alreadyContact.authStatus == .friend {
        statusSubject.send(.failed(.alreadyFriends(username)))
      } else if [.requested, .verified].contains(alreadyContact.authStatus) {
        statusSubject.send(.failed(.requestOpened))
      } else {
        let generalErrorTitle = Localized.Scan.Error.general
        statusSubject.send(.failed(.unknown(generalErrorTitle)))
      }

      return
    }

    statusSubject.send(.success)
    cameraSemaphoreSubject.send(false)

    foundSubject.send(.init(
      id: uid,
      marshaled: data,
      username: username,
      email: email,
      phone: phone,
      nickname: nil,
      photo: nil,
      authStatus: .stranger,
      isRecent: false,
      createdAt: Date()
    ))
  }
}
