import UIKit
import Models
import Combine
import Defaults
import Keychain
import SFTPFeature
import iCloudFeature
import DropboxFeature
import NetworkMonitor
import GoogleDriveFeature
import DependencyInjection

public final class BackupService {
    @Dependency private var sftpService: SFTPService
    @Dependency private var icloudService: iCloudInterface
    @Dependency private var dropboxService: DropboxInterface
    @Dependency private var networkManager: NetworkMonitoring
    @Dependency private var keychainHandler: KeychainHandling
    @Dependency private var driveService: GoogleDriveInterface

    @KeyObject(.backupSettings, defaultValue: Data()) private var storedSettings: Data

    public var passphrase: String?

    public var settingsPublisher: AnyPublisher<BackupSettings, Never> {
        settings.handleEvents(receiveSubscription: { [weak self] _ in
            guard let self = self else { return }

            let lastRefreshDate = self.settingsLastRefreshedDate ?? Date.distantPast

            if Date().timeIntervalSince(lastRefreshDate) < 10 { return }

            self.settingsLastRefreshedDate = Date()
            self.refreshConnections()
            self.refreshBackups()
        }).eraseToAnyPublisher()
    }

    private var connType: ConnectionType = .wifi
    private var settingsLastRefreshedDate: Date?
    private var cancellables = Set<AnyCancellable>()
    private lazy var settings = CurrentValueSubject<BackupSettings, Never>(.init(fromData: storedSettings))

    public init() {
        settings
            .dropFirst()
            .removeDuplicates()
            .sink { [unowned self] in storedSettings = $0.toData() }
            .store(in: &cancellables)

        networkManager.connType
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in connType = $0 }
            .store(in: &cancellables)
    }
}

extension BackupService {
    public func performBackupIfAutomaticIsEnabled() {
        guard settings.value.automaticBackups == true else { return }
        performBackup()
    }

    public func performBackup() {
        guard let directoryUrl = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { fatalError("Couldn't generate the URL to persist the backup") }

        let fileUrl = directoryUrl
            .appendingPathComponent("backup")
            .appendingPathExtension("xxm")

        guard let data = try? Data(contentsOf: fileUrl) else {
            print(">>> Tried to backup arbitrarily but there was nothing to be backed up. Aborting...")
            return
        }

        performBackup(data: data)
    }

    public func updateBackup(data: Data) {
        guard let directoryUrl = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { fatalError("Couldn't generate the URL to persist the backup") }

        let fileUrl = directoryUrl
            .appendingPathComponent("backup")
            .appendingPathExtension("xxm")

        do {
            try data.write(to: fileUrl)
        } catch {
            fatalError("Couldn't write backup to fileurl")
        }

        let isWifiOnly = settings.value.wifiOnlyBackup
        let isAutomaticEnabled = settings.value.automaticBackups
        let hasEnabledService = settings.value.enabledService != nil

        if isWifiOnly {
            guard connType == .wifi else { return }
        } else {
            guard connType != .unknown else { return }
        }

        if isAutomaticEnabled && hasEnabledService {
            performBackup()
        }
    }

    public func setBackupOnlyOnWifi(_ enabled: Bool) {
        settings.value.wifiOnlyBackup = enabled
    }

    public func setBackupAutomatically(_ enabled: Bool) {
        settings.value.automaticBackups = enabled

        guard enabled else { return }
        performBackup()
    }

    public func toggle(service: CloudService, enabling: Bool) {
        settings.value.enabledService = enabling ? service : nil
    }

    public func authorize(service: CloudService, presenting screen: UIViewController) {
        switch service {
        case .drive:
            driveService.authorize(presenting: screen) { [weak self] _ in
                guard let self = self else { return }
                self.refreshConnections()
                self.refreshBackups()
            }
        case .icloud:
            if !icloudService.isAuthorized() {
                icloudService.openSettings()
            } else {
                refreshConnections()
                refreshBackups()
            }
        case .dropbox:
            if !dropboxService.isAuthorized() {
                dropboxService.authorize(presenting: screen)
                    .sink { [weak self] _ in
                        guard let self = self else { return }
                        self.refreshConnections()
                        self.refreshBackups()
                    }.store(in: &cancellables)
            }
        case .sftp:
            if !sftpService.isAuthorized() {
                sftpService.authorizeFlow((screen, { [weak self] in
                    guard let self = self else { return }
                    screen.navigationController?.popViewController(animated: true)
                    self.refreshConnections()
                    self.refreshBackups()
                }))
            }
        }
    }
}

extension BackupService {
    private func refreshConnections() {
        if icloudService.isAuthorized() && !settings.value.connectedServices.contains(.icloud) {
            settings.value.connectedServices.insert(.icloud)
        } else if !icloudService.isAuthorized() && settings.value.connectedServices.contains(.icloud) {
            settings.value.connectedServices.remove(.icloud)
        }

        if dropboxService.isAuthorized() && !settings.value.connectedServices.contains(.dropbox) {
            settings.value.connectedServices.insert(.dropbox)
        } else if !dropboxService.isAuthorized() && settings.value.connectedServices.contains(.dropbox) {
            settings.value.connectedServices.remove(.dropbox)
        }

        if sftpService.isAuthorized() && !settings.value.connectedServices.contains(.sftp) {
            settings.value.connectedServices.insert(.sftp)
        } else if !sftpService.isAuthorized() && settings.value.connectedServices.contains(.sftp) {
            settings.value.connectedServices.remove(.sftp)
        }

        driveService.isAuthorized { [weak settings] isAuthorized in
            guard let settings = settings else { return }

            if isAuthorized && !settings.value.connectedServices.contains(.drive) {
                settings.value.connectedServices.insert(.drive)
            } else if !isAuthorized && settings.value.connectedServices.contains(.drive) {
                settings.value.connectedServices.remove(.drive)
            }
        }
    }

    private func refreshBackups() {
        if icloudService.isAuthorized() {
            icloudService.downloadMetadata { [weak settings] in
                guard let settings = settings else { return }

                guard let metadata = try? $0.get() else {
                    settings.value.backups[.icloud] = nil
                    return
                }

                settings.value.backups[.icloud] = Backup(
                    id: metadata.path,
                    date: metadata.modifiedDate,
                    size: metadata.size
                )
            }
        }

        if sftpService.isAuthorized() {
            sftpService.fetchMetadata { [weak settings] in
                guard let settings = settings else { return }

                guard let metadata = try? $0.get()?.backup else {
                    settings.value.backups[.sftp] = nil
                    return
                }

                settings.value.backups[.sftp] = Backup(
                    id: metadata.id,
                    date: metadata.date,
                    size: metadata.size
                )
            }
        }

        if dropboxService.isAuthorized() {
            dropboxService.downloadMetadata { [weak settings] in
                guard let settings = settings else { return }

                guard let metadata = try? $0.get() else {
                    settings.value.backups[.dropbox] = nil
                    return
                }

                settings.value.backups[.dropbox] = Backup(
                    id: metadata.path,
                    date: metadata.modifiedDate,
                    size: metadata.size
                )
            }
        }

        driveService.isAuthorized { [weak settings] isAuthorized  in
            guard let settings = settings else { return }

            if isAuthorized {
                self.driveService.downloadMetadata {
                    guard let metadata = try? $0.get() else { return }

                    settings.value.backups[.drive] = Backup(
                        id: metadata.identifier,
                        date: metadata.modifiedDate,
                        size: metadata.size
                    )
                }
            } else {
                settings.value.backups[.drive] = nil
            }
        }
    }

    private func performBackup(data: Data) {
        guard let enabledService = settings.value.enabledService else {
            fatalError("Trying to backup but nothing is enabled")
        }

        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)

        do {
            try data.write(to: url, options: .atomic)
        } catch {
            print("Couldn't write to temp: \(error.localizedDescription)")
            return
        }

        switch enabledService {
        case .drive:
            driveService.uploadBackup(url) {
                switch $0 {
                case .success(let metadata):
                    self.settings.value.backups[.drive] = .init(
                        id: metadata.identifier,
                        date: metadata.modifiedDate,
                        size: metadata.size
                    )
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case .icloud:
            icloudService.uploadBackup(url) {
                switch $0 {
                case .success(let metadata):
                    self.settings.value.backups[.icloud] = .init(
                        id: metadata.path,
                        date: metadata.modifiedDate,
                        size: metadata.size
                    )
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case .dropbox:
            dropboxService.uploadBackup(url) {
                switch $0 {
                case .success(let metadata):
                    self.settings.value.backups[.dropbox] = .init(
                        id: metadata.path,
                        date: metadata.modifiedDate,
                        size: metadata.size
                    )
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case .sftp:
            sftpService.uploadBackup(url: url) {
                switch $0 {
                case .success(let backup):
                    self.settings.value.backups[.sftp] = backup
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
