import UIKit
import Shared
import AppCore
import Combine
import CloudFiles
import CloudFilesSFTP
import ComposableArchitecture

public struct RestorationDetails {
  var provider: CloudService
  var metadata: Fetch.Metadata?
}

final class RestoreListViewModel {
  @Dependency(\.app.hudManager) var hudManager: HUDManager

  var sftpPublisher: AnyPublisher<Void, Never> {
    sftpSubject.eraseToAnyPublisher()
  }

  var detailsPublisher: AnyPublisher<RestorationDetails, Never> {
    detailsSubject.eraseToAnyPublisher()
  }

  private let sftpSubject = PassthroughSubject<Void, Never>()
  private let detailsSubject = PassthroughSubject<RestorationDetails, Never>()

  func setupSFTP(host: String, username: String, password: String) {
    CloudFilesManager.all[.sftp] = .sftp(
      host: host,
      username: username,
      password: password,
      fileName: "backup.xxm"
    )
    fetch(provider: .sftp)
  }

  func link(
    provider: CloudService,
    from controller: UIViewController,
    onSuccess: @escaping () -> Void
  ) {
    if provider == .sftp {
      sftpSubject.send(())
      return
    }
    do {
      try CloudFilesManager.all[provider]!.link(controller) { [weak self] in
        guard let self else {return }

        switch $0 {
        case .success:
          onSuccess()
        case .failure(let error):
          self.hudManager.show(.init(error: error))
        }
      }
    } catch {
      hudManager.show(.init(error: error))
    }
  }

  func fetch(provider: CloudService) {
    hudManager.show()
    do {
      try CloudFilesManager.all[provider]!.fetch { [weak self] in
        guard let self else { return }

        switch $0 {
        case .success(let metadata):
          self.hudManager.hide()
          self.detailsSubject.send(.init(
            provider: provider,
            metadata: metadata
          ))
        case .failure(let error):
          self.hudManager.show(.init(error: error))
        }
      }
    } catch {
      hudManager.show(.init(error: error))
    }
  }
}
