import UIKit
import Shout
import Socket
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

final class BackupSFTPViewModel {
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
            var message = "An error occurred while trying to link SFTP: "

            if case let CloudFilesSFTP.SFTP.SFTPError.link(linkError) = error {
              if let sshError = linkError as? SSHError {
                message.append(sshError.message)
              } else if let socketError = linkError as? Socket.Error, let reason = socketError.errorReason {
                message.append(reason)
              } else {
                message.append(error.localizedDescription)
              }
            } else {
              message.append(error.localizedDescription)
            }

            self.hudManager.show(.init(content: message))
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
