import UIKit
import Models
import Shared
import Combine
import Defaults
import Foundation
import Integration
import BackupFeature
import DependencyInjection

import SFTPFeature
import iCloudFeature
import DropboxFeature
import GoogleDriveFeature

enum RestorationStep {
    case idle(CloudService, Backup?)
    case downloading(Float, Float)
    case failDownload(Error)
    case wrongPass
    case parsingData
    case done
}

extension RestorationStep: Equatable {
    static func ==(lhs: RestorationStep, rhs: RestorationStep) -> Bool {
        switch (lhs, rhs) {
        case (.done, .done), (.wrongPass, .wrongPass):
            return true
        case let (.failDownload(a), .failDownload(b)):
            return a.localizedDescription == b.localizedDescription
        case let (.downloading(a, b), .downloading(c, d)):
            return a == c && b == d
        case (.idle, _), (.downloading, _), (.parsingData, _),
            (.done, _), (.failDownload, _), (.wrongPass, _):
            return false
        }
    }
}

final class RestoreViewModel {
    @Dependency private var sftpService: SFTPService
    @Dependency private var iCloudService: iCloudInterface
    @Dependency private var dropboxService: DropboxInterface
    @Dependency private var googleService: GoogleDriveInterface

    @KeyObject(.username, defaultValue: nil) var username: String?

    var step: AnyPublisher<RestorationStep, Never> {
        stepRelay.eraseToAnyPublisher()
    }

    // TO REFACTOR:
    //
    private var pendingData: Data?

    private let ndf: String
    private var passphrase: String!
    private let settings: RestoreSettings
    private let stepRelay: CurrentValueSubject<RestorationStep, Never>

    init(ndf: String, settings: RestoreSettings) {
        self.ndf = ndf
        self.settings = settings
        self.stepRelay = .init(.idle(settings.cloudService, settings.backup))
    }

    func retryWith(passphrase: String) {
        self.passphrase = passphrase
        continueRestoring(data: pendingData!)
    }

    func didTapRestore(passphrase: String) {
        self.passphrase = passphrase

        guard let backup = settings.backup else { fatalError() }

        stepRelay.send(.downloading(0.0, backup.size))

        switch settings.cloudService {
        case .drive:
            downloadBackupForDrive(backup)
        case .dropbox:
            downloadBackupForDropbox(backup)
        case .icloud:
            downloadBackupForiCloud(backup)
        case .sftp:
            downloadBackupForSFTP(backup)
        }
    }

    private func downloadBackupForSFTP(_ backup: Backup) {
        sftpService.downloadBackup(backup.id, { [weak self] in
            guard let self = self else { return }
            self.stepRelay.send(.downloading(backup.size, backup.size))

            switch $0 {
            case .success(let data):
                self.continueRestoring(data: data)
            case .failure(let error):
                self.stepRelay.send(.failDownload(error))
            }
        })
    }

    private func downloadBackupForDropbox(_ backup: Backup) {
        dropboxService.downloadBackup(backup.id) { [weak self] in
            guard let self = self else { return }
            self.stepRelay.send(.downloading(backup.size, backup.size))

            switch $0 {
            case .success(let data):
                self.continueRestoring(data: data)
            case .failure(let error):
                self.stepRelay.send(.failDownload(error))
            }
        }
    }

    private func downloadBackupForiCloud(_ backup: Backup) {
        iCloudService.downloadBackup(backup.id) { [weak self] in
            guard let self = self else { return }
            self.stepRelay.send(.downloading(backup.size, backup.size))

            switch $0 {
            case .success(let data):
                self.continueRestoring(data: data)
            case .failure(let error):
                self.stepRelay.send(.failDownload(error))
            }
        }
    }

    private func downloadBackupForDrive(_ backup: Backup) {
        googleService.downloadBackup(backup.id) { [weak self] in
            if let stepRelay = self?.stepRelay {
                stepRelay.send(.downloading($0, backup.size))
            }
        } _: { [weak self] in
            guard let self = self else { return }

            switch $0 {
            case .success(let data):
                self.continueRestoring(data: data)
            case .failure(let error):
                self.stepRelay.send(.failDownload(error))
            }
        }
    }

    private func continueRestoring(data: Data) {
        stepRelay.send(.parsingData)

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            do {
                let session = try Session(
                    passphrase: self.passphrase,
                    backupFile: data,
                    ndf: self.ndf
                )

                DependencyInjection.Container.shared.register(session as SessionType)
                self.stepRelay.send(.done)
            } catch {
                self.pendingData = data
                self.stepRelay.send(.wrongPass)
            }
        }
    }
}
