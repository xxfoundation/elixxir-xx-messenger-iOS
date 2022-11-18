import UIKit
import Shared
import Combine
import Foundation
import CloudFiles
import CloudFilesSFTP

import AppCore
import ComposableArchitecture

struct SFTPViewState {
  var host: String = ""
  var username: String = ""
  var password: String = ""
  var isButtonEnabled: Bool = false
}

final class RestoreSFTPViewModel {
  @Dependency(\.app.hudManager) var hudManager: HUDManager

  var statePublisher: AnyPublisher<SFTPViewState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  var authPublisher: AnyPublisher<(String, String, String), Never> {
    authSubject.eraseToAnyPublisher()
  }

  private let stateSubject = CurrentValueSubject<SFTPViewState, Never>(.init())
  private let authSubject = PassthroughSubject<(String, String, String), Never>()

  func didEnterHost(_ string: String) {
    stateSubject.value.host = string
    validate()
  }

  func didEnterUsername(_ string: String) {
    stateSubject.value.username = string
    validate()
  }

  func didEnterPassword(_ string: String) {
    stateSubject.value.password = string
    validate()
  }

  func didTapLogin() {
    hudManager.show()

    let host = stateSubject.value.host
    let username = stateSubject.value.username
    let password = stateSubject.value.password

    let anyController = UIViewController()

    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      do {
        try CloudFilesManager.sftp(
          host: host,
          username: username,
          password: password,
          fileName: "backup.xxm"
        ).link(anyController) {
          switch $0 {
          case .success:
            self.hudManager.hide()
            self.authSubject.send((host, username, password))
          case .failure(let error):
            self.hudManager.show(.init(error: error))
          }
        }
      } catch {
        self.hudManager.show(.init(error: error))
      }
    }
  }

  private func validate() {
    stateSubject.value.isButtonEnabled =
    !stateSubject.value.host.isEmpty &&
    !stateSubject.value.username.isEmpty &&
    !stateSubject.value.password.isEmpty
  }
}
