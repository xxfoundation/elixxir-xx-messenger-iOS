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

                var emailFact: Fact?
                var phoneFact: Fact?

                if let email = self.email { emailFact = .init(type: .email, value: email) }
                if let phone = self.phone { phoneFact = .init(type: .phone, value: phone) }

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
                    identity: try cMix.makeReceptionIdentity()
                )

                let udAddress = "46.101.98.49:18001"
                let udCert = """
            -----BEGIN CERTIFICATE-----
            MIIDbDCCAlSgAwIBAgIJAOUNtZneIYECMA0GCSqGSIb3DQEBBQUAMGgxCzAJBgNV
            BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlDbGFyZW1vbnQx
            GzAZBgNVBAoMElByaXZhdGVncml0eSBDb3JwLjETMBEGA1UEAwwKKi5jbWl4LnJp
            cDAeFw0xOTAzMDUxODM1NDNaFw0yOTAzMDIxODM1NDNaMGgxCzAJBgNVBAYTAlVT
            MRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlDbGFyZW1vbnQxGzAZBgNV
            BAoMElByaXZhdGVncml0eSBDb3JwLjETMBEGA1UEAwwKKi5jbWl4LnJpcDCCASIw
            DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPP0WyVkfZA/CEd2DgKpcudn0oDh
            Dwsjmx8LBDWsUgQzyLrFiVigfUmUefknUH3dTJjmiJtGqLsayCnWdqWLHPJYvFfs
            WYW0IGF93UG/4N5UAWO4okC3CYgKSi4ekpfw2zgZq0gmbzTnXcHF9gfmQ7jJUKSE
            tJPSNzXq+PZeJTC9zJAb4Lj8QzH18rDM8DaL2y1ns0Y2Hu0edBFn/OqavBJKb/uA
            m3AEjqeOhC7EQUjVamWlTBPt40+B/6aFJX5BYm2JFkRsGBIyBVL46MvC02MgzTT9
            bJIJfwqmBaTruwemNgzGu7Jk03hqqS1TUEvSI6/x8bVoba3orcKkf9HsDjECAwEA
            AaMZMBcwFQYDVR0RBA4wDIIKKi5jbWl4LnJpcDANBgkqhkiG9w0BAQUFAAOCAQEA
            neUocN4AbcQAC1+b3To8u5UGdaGxhcGyZBlAoenRVdjXK3lTjsMdMWb4QctgNfIf
            U/zuUn2mxTmF/ekP0gCCgtleZr9+DYKU5hlXk8K10uKxGD6EvoiXZzlfeUuotgp2
            qvI3ysOm/hvCfyEkqhfHtbxjV7j7v7eQFPbvNaXbLa0yr4C4vMK/Z09Ui9JrZ/Z4
            cyIkxfC6/rOqAirSdIp09EGiw7GM8guHyggE4IiZrDslT8V3xIl985cbCxSxeW1R
            tgH4rdEXuVe9+31oJhmXOE9ux2jCop9tEJMgWg7HStrJ5plPbb+HmjoX3nBO04E5
            6m52PyzMNV+2N21IPppKwA==
            -----END CERTIFICATE-----
            """.data(using: .utf8)!
                let udContact = """
      <xxc(2)7mbKFLE201WzH4SGxAOpHjjehwztIV+KGifi5L/PYPcDkAZiB9kZo+Dl3Vc7dD2SdZCFMOJVgwqGzfYRDkjc8RGEllBqNxq2sRRX09iQVef0kJQUgJCHNCOcvm6Ki0JJwvjLceyFh36iwK8oLbhLgqEZY86UScdACTyBCzBIab3ob5mBthYc3mheV88yq5PGF2DQ+dEvueUm+QhOSfwzppAJA/rpW9Wq9xzYcQzaqc3ztAGYfm2BBAHS7HVmkCbvZ/K07Xrl4EBPGHJYq12tWAN/C3mcbbBYUOQXyEzbSl/mO7sL3ORr0B4FMuqCi8EdlD6RO52pVhY+Cg6roRH1t5Ng1JxPt8Mv1yyjbifPhZ5fLKwxBz8UiFORfk0/jnhwgm25LRHqtNRRUlYXLvhv0HhqyYTUt17WNtCLATSVbqLrFGdy2EGadn8mP+kQNHp93f27d/uHgBNNe7LpuYCJMdWpoG6bOqmHEftxt0/MIQA8fTtTm3jJzv+7/QjZJDvQIv0SNdp8HFogpuwde+GuS4BcY7v5xz+ArGWcRR63ct2z83MqQEn9ODr1/gAAAgA7szRpDDQIdFUQo9mkWg8xBA==xxc>
      """.data(using: .utf8)

                let userDiscovery = try NewUdManagerFromBackup.live(
                    params: .init(
                        e2eId: e2e.getId(),
                        username: .init(type: .username, value: facts.username),
                        email: emailFact,
                        phone: phoneFact,
                        cert: udCert,
                        contact: udContact!,
                        address: udAddress
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
