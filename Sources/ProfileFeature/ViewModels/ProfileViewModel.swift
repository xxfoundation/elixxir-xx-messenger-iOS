import UIKit
import Shared
import AppCore
import Combine
import Defaults
import XXClient
import BackupFeature
import XXMessengerClient
import CombineSchedulers
import CountryListFeature
import PermissionsFeature
import ComposableArchitecture

enum ProfileNavigationRoutes {
  case none
  case library
  case libraryPermission
}

struct ProfileViewState: Equatable {
  var email: String?
  var phone: String?
  var photo: UIImage?
}

final class ProfileViewModel {
  @KeyObject(.avatar, defaultValue: nil) var avatar: Data?
  @KeyObject(.email, defaultValue: nil) var emailStored: String?
  @KeyObject(.phone, defaultValue: nil) var phoneStored: String?
  @KeyObject(.username, defaultValue: nil) var username: String?
  @KeyObject(.sharingEmail, defaultValue: false) var isEmailSharing: Bool
  @KeyObject(.sharingPhone, defaultValue: false) var isPhoneSharing: Bool

  @Dependency(\.app.bgQueue) var bgQueue
  @Dependency(\.permissions) var permissions
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.hudManager) var hudManager
  @Dependency(\.backupService) var backupService

  var name: String { username! }

  var state: AnyPublisher<ProfileViewState, Never> {
    stateRelay.eraseToAnyPublisher()
  }
  private let stateRelay = CurrentValueSubject<ProfileViewState, Never>(.init())

  var navigation: AnyPublisher<ProfileNavigationRoutes, Never> {
    navigationRoutes.eraseToAnyPublisher()
  }
  private let navigationRoutes = PassthroughSubject<ProfileNavigationRoutes, Never>()

  init() {
    refresh()
  }

  func refresh() {
    var cleanPhone = phoneStored

    if let phone = cleanPhone {
      let country = Country.findFrom(phone)
      cleanPhone = "\(country.prefix)\(phone.dropLast(2))"
    }

    stateRelay.value = .init(
      email: emailStored,
      phone: cleanPhone,
      photo: avatar != nil ? UIImage(data: avatar!) : nil
    )
  }

  func didRequestLibraryAccess() {
    if permissions.library.status() {
      navigationRoutes.send(.library)
    } else {
      navigationRoutes.send(.libraryPermission)
    }
  }

  func didNavigateSomewhere() {
    navigationRoutes.send(.none)
  }

  func didChoosePhoto(_ photo: UIImage) {
    stateRelay.value.photo = photo
    avatar = photo.jpegData(compressionQuality: 0.0)
  }

  func didTapDelete(isEmail: Bool) {
    hudManager.show()

    bgQueue.schedule { [weak self] in
      guard let self else { return }
      do {
        try self.messenger.ud.tryGet().removeFact(
          .init(
            type: isEmail ? .email : .phone,
            value: isEmail ? self.emailStored! : self.phoneStored!
          )
        )
        if isEmail {
          self.emailStored = nil
          self.isEmailSharing = false
        } else {
          self.phoneStored = nil
          self.isPhoneSharing = false
        }
        self.backupService.didUpdateFacts()
        self.hudManager.hide()
        self.refresh()
      } catch {
        let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
        self.hudManager.show(.init(content: xxError))
      }
    }
  }
}
