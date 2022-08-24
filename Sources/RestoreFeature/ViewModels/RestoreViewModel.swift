import UIKit
import Models
import Shared
import Combine
import Defaults
import Foundation
import BackupFeature
import DependencyInjection

import SFTPFeature
import iCloudFeature
import DropboxFeature
import GoogleDriveFeature

import XXClient
import struct Models.Backup

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
    @Dependency var cMixManager: CMixManager

    @Dependency private var sftpService: SFTPService
    @Dependency private var iCloudService: iCloudInterface
    @Dependency private var dropboxService: DropboxInterface
    @Dependency private var googleService: GoogleDriveInterface

    @KeyObject(.username, defaultValue: nil) var username: String?
    @KeyObject(.phone, defaultValue: nil) var phone: String?
    @KeyObject(.email, defaultValue: nil) var email: String?

    var step: AnyPublisher<RestorationStep, Never> {
        stepRelay.eraseToAnyPublisher()
    }

    // TO REFACTOR:
    //
    private var pendingData: Data?

    private var passphrase: String!
    private let settings: RestoreSettings
    private let stepRelay: CurrentValueSubject<RestorationStep, Never>

    init(settings: RestoreSettings) {
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
        sftpService.downloadBackup(path: backup.id) { [weak self] in
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
                let report = try self.cMixManager.restore(
                    backup: data,
                    passphrase: self.passphrase
                )

                struct BackupParameters: Codable {
                    var email: String?
                    var phone: String?
                    var username: String
                }

                guard let paramsData = report.params.data(using: .utf8) else {
                    fatalError("Couldn't parse parameters from backup to byte array")
                }

                let facts = try JSONDecoder().decode(
                    BackupParameters.self,
                    from: paramsData
                )

                self.phone = facts.phone
                self.email = facts.email

                var emailFact: Fact? = {
                    if let email = facts.email { return Fact(fact: email, type: FactType.email.rawValue) }
                    return nil
                }()

                var phoneFact: Fact? = {
                    if let phone = facts.phone { return Fact(fact: phone, type: FactType.phone.rawValue) }
                    return nil
                }()

                let cMix = try self.cMixManager.load()

                DependencyInjection.Container.shared.register(cMix)

                let e2e = try Login.live(
                    cMixId: cMix.getId(),
                    authCallbacks: .init(
                        handle: { callbacks in
                            switch callbacks {
                            case .reset(
                                contact: _,
                                receptionId: _,
                                ephemeralId: _,
                                roundId: _
                            ):
                                break
                            case .confirm(
                                contact: _,
                                receptionId: _,
                                ephemeralId: _,
                                roundId: _
                            ):
                                break
                            case .request(
                                contact: _,
                                receptionId: _,
                                ephemeralId: _,
                                roundId: _
                            ):
                                break
                            }
                        }
                    ),
                    identity: try cMix.makeLegacyReceptionIdentity()
                )

                guard let certPath = Bundle.module.path(forResource: "cmix.rip", ofType: "crt"),
                      let contactFilePath = Bundle.module.path(forResource: "udContact", ofType: "bin") else {
                    fatalError("Couldn't retrieve alternative UD credentials")
                }

                let userDiscovery = try NewUdManagerFromBackup.live(
                    params: .init(
                        e2eId: e2e.getId(),
                        username: Fact(fact: facts.username, type: 0),
                        email: emailFact,
                        phone: phoneFact,
                        cert: Data(contentsOf: URL(fileURLWithPath: certPath)),
                        contactFile: Data(contentsOf: URL(fileURLWithPath: contactFilePath)),
                        address: "46.101.98.49:18001"
                    ),
                    follower: .init(handle: { cMix.networkFollowerStatus() })
                )

                DependencyInjection.Container.shared.register(userDiscovery)

                try e2e.registerListener(
                    senderId: nil,
                    messageType: 2,
                    callback: .init(handle: { message in
                        print(message.timestamp)
                    })
                )

                DependencyInjection.Container.shared.register(e2e)

                let groupManager = try NewGroupChat.live(
                    e2eId: e2e.getId(),
                    groupRequest: .init(handle: {
                        print($0)
                    }),
                    groupChatProcessor: .init(handle: {
                        print($0)
                    })
                )

                DependencyInjection.Container.shared.register(groupManager)

                let transferManager = try InitFileTransfer.live(
                    e2eId: e2e.getId(),
                    callback: .init(handle: {
                        switch $0 {
                        case .success(let receivedFile):
                            print(receivedFile.name)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    })
                )

                DependencyInjection.Container.shared.register(transferManager)

                self.stepRelay.send(.done)
            } catch {
                self.pendingData = data
                self.stepRelay.send(.wrongPass)
            }
        }
    }
}
