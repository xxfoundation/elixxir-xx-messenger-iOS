import HUD
import UIKit
import Models
import Shared
import Combine
import BackupFeature
import DependencyInjection

import SFTPFeature
import iCloudFeature
import DropboxFeature
import GoogleDriveFeature

final class RestoreListViewModel {
    @Dependency private var sftpService: SFTPService
    @Dependency private var icloudService: iCloudInterface
    @Dependency private var dropboxService: DropboxInterface
    @Dependency private var googleDriveService: GoogleDriveInterface

    var hud: AnyPublisher<HUDStatus, Never> { hudSubject.eraseToAnyPublisher() }
    var didFetchBackup: AnyPublisher<RestoreSettings, Never> { backupSubject.eraseToAnyPublisher() }

    private var dropboxAuthCancellable: AnyCancellable?

    private let hudSubject = PassthroughSubject<HUDStatus, Never>()
    private let backupSubject = PassthroughSubject<RestoreSettings, Never>()

    func didTapCloud(_ cloudService: CloudService, from parent: UIViewController) {
        switch cloudService {
        case .drive:
            didRequestDriveAuthorization(from: parent)
        case .icloud:
            didRequestICloudAuthorization()
        case .dropbox:
            didRequestDropboxAuthorization(from: parent)
        case .sftp:
            didRequestSFTPAuthorization()
        }
    }

    private func didRequestDriveAuthorization(from controller: UIViewController) {
        googleDriveService.authorize(presenting: controller) { authResult in
            switch authResult {
            case .success:
                self.hudSubject.send(.on(nil))
                self.googleDriveService.downloadMetadata { downloadResult in
                    switch downloadResult {
                    case .success(let metadata):
                        var backup: Backup?

                        if let metadata = metadata {
                            backup = .init(id: metadata.identifier, date: metadata.modifiedDate, size: metadata.size)
                        }

                        self.hudSubject.send(.none)
                        self.backupSubject.send(RestoreSettings(backup: backup, cloudService: .drive))

                    case .failure(let error):
                        self.hudSubject.send(.error(.init(with: error)))
                    }
                }
            case .failure(let error):
                self.hudSubject.send(.error(.init(with: error)))
            }
        }
    }

    private func didRequestICloudAuthorization() {
        if icloudService.isAuthorized() {
            self.hudSubject.send(.on(nil))

            icloudService.downloadMetadata { result in
                switch result {
                case .success(let metadata):
                    var backup: Backup?

                    if let metadata = metadata {
                        backup = .init(id: metadata.path, date: metadata.modifiedDate, size: metadata.size)
                    }

                    self.hudSubject.send(.none)
                    self.backupSubject.send(RestoreSettings(backup: backup, cloudService: .icloud))
                case .failure(let error):
                    self.hudSubject.send(.error(.init(with: error)))
                }
            }
        } else {
            /// This could be an alert controller asking if user wants to enable/deeplink
            ///
            icloudService.openSettings()
        }
    }

    private func didRequestDropboxAuthorization(from controller: UIViewController) {
        dropboxAuthCancellable = dropboxService.authorize(presenting: controller)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] authResult in
                switch authResult {
                case .success(let bool):
                    guard bool == true else { return }

                    self.hudSubject.send(.on(nil))
                    dropboxService.downloadMetadata { metadataResult in
                        switch metadataResult {
                        case .success(let metadata):
                            var backup: Backup?

                            if let metadata = metadata {
                                backup = .init(id: metadata.path, date: metadata.modifiedDate, size: metadata.size)
                            }

                            self.hudSubject.send(.none)
                            self.backupSubject.send(RestoreSettings(backup: backup, cloudService: .dropbox))

                        case .failure(let error):
                            self.hudSubject.send(.error(.init(with: error)))
                        }
                    }
                case .failure(let error):
                    self.hudSubject.send(.error(.init(with: error)))
                }
            }
    }
}
