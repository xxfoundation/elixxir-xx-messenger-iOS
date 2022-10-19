import HUD
import UIKit
import Combine

import CloudFiles
import CloudFilesSFTP
import CloudFilesDrive
import CloudFilesICloud
import CloudFilesDropbox

import DependencyInjection

enum RestorationProvider: String, Equatable, Hashable {
  case sftp
  case drive
  case icloud
  case dropbox
}

public struct RestorationDetails {
  var provider: RestorationProvider
  var metadata: Fetch.Metadata?
}

final class RestoreListViewModel {
  var sftpPublisher: AnyPublisher<Void, Never> {
    sftpSubject.eraseToAnyPublisher()
  }

  var hudPublisher: AnyPublisher<HUDStatus, Never> {
    hudSubject.eraseToAnyPublisher()
  }

  var detailsPublisher: AnyPublisher<RestorationDetails, Never> {
    detailsSubject.eraseToAnyPublisher()
  }

  private var managers: [RestorationProvider: CloudFilesManager] = [
    .icloud: .iCloud(
      fileName: "backup.xxm"
    ),
    .dropbox: .dropbox(
      appKey: PlistSecrets.dropboxAppKey,
      path: "/backup/backup.xxm"
    ),
    .drive: .drive(
      apiKey: PlistSecrets.googleAPIKey,
      clientId: PlistSecrets.googleClientId,
      fileName: "backup.xxm"
    )
  ]

  private let sftpSubject = PassthroughSubject<Void, Never>()
  private let hudSubject = PassthroughSubject<HUDStatus, Never>()
  private let detailsSubject = PassthroughSubject<RestorationDetails, Never>()

  func setupSFTP(host: String, username: String, password: String) {
    managers[.sftp] = .sftp(
      host: host,
      username: username,
      password: password,
      fileName: "backup.xxm"
    )
    fetch(provider: .sftp)
  }

  func link(
    provider: RestorationProvider,
    from controller: UIViewController,
    onSuccess: @escaping () -> Void
  ) {
    if provider == .sftp {
      sftpSubject.send(())
      return
    }
    guard let manager = managers[provider] else {
      return
    }
    do {
      try manager.link(controller) { [weak self] in
        guard let self else {return }

        switch $0 {
        case .success:
          onSuccess()
        case .failure(let error):
          self.hudSubject.send(.error(.init(with: error)))
        }
      }
    } catch {
      hudSubject.send(.error(.init(with: error)))
    }
  }

  func fetch(provider: RestorationProvider) {
    guard let manager = managers[provider] else {
      return
    }
    do {
      try manager.fetch { [weak self] in
        guard let self else { return }

        switch $0 {
        case .success(let metadata):
          DependencyInjection.Container.shared.register(manager)

          self.detailsSubject.send(.init(
            provider: provider,
            metadata: metadata
          ))
        case .failure(let error):
          self.hudSubject.send(.error(.init(with: error)))
        }
      }
    } catch {
      hudSubject.send(.error(.init(with: error)))
    }
  }
}
