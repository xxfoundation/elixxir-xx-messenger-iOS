import UIKit
import Models
import Combine
import Defaults
import Keychain
import NetworkMonitor
import DependencyInjection
import XXClient
import XXMessengerClient

public final class BackupService {
  @Dependency var messenger: Messenger
  @Dependency var sftpService: SFTPService
  @Dependency var icloudService: iCloudInterface
  @Dependency var dropboxService: DropboxInterface
  @Dependency var networkManager: NetworkMonitoring
  @Dependency var keychainHandler: KeychainHandling
  @Dependency var driveService: GoogleDriveInterface

  @KeyObject(.username, defaultValue: nil) var username: String?
  @KeyObject(.backupSettings, defaultValue: nil) var storedSettings: Data?

  public var settingsPublisher: AnyPublisher<BackupSettings, Never> {
    settings.handleEvents(receiveSubscription: { [weak self] _ in
      guard let self = self else { return }
      self.refreshConnections()
      self.refreshBackups()
    }).eraseToAnyPublisher()
  }

  private var connType: ConnectionType = .wifi
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
  public func stopBackups() {
    print(">>> [AccountBackup] Requested to stop backup mechanism")

    if messenger.isBackupRunning() == true {
      print(">>> [AccountBackup] messenger.isBackupRunning() == true")
      try! messenger.stopBackup()

      print(">>> [AccountBackup] Stopped backup mechanism")
    }
  }

  public func initializeBackup(passphrase: String) {
    try! messenger.startBackup(
      password: passphrase,
      params: .init(username: username!)
    )

    print(">>> [AccountBackup] Initialized backup mechanism")
  }

  public func performBackupIfAutomaticIsEnabled() {
    print(">>> [AccountBackup] Requested backup if automatic is enabled")

    guard settings.value.automaticBackups == true else { return }
    performBackup()
  }

  public func performBackup() {
    print(">>> [AccountBackup] Requested backup without explicitly passing data")

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
      print(">>> [AccountBackup] Tried to backup arbitrarily but there was nothing to be backed up. Aborting...")
      return
    }

    performBackup(data: data)
  }

  public func updateBackup(data: Data) {
    print(">>> [AccountBackup] Requested to update backup passing data")

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

    refreshBackups()
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
    print(">>> Refreshing backups...")

    if icloudService.isAuthorized() {
      print(">>> Refreshing icloud backup...")

      icloudService.downloadMetadata { [weak settings] in
        guard let settings = settings else { return }

        guard let metadata = try? $0.get() else {
          settings.value.backups[.icloud] = nil
          return
        }

        settings.value.backups[.icloud] = BackupModel(
          id: metadata.path,
          date: metadata.modifiedDate,
          size: metadata.size
        )
      }
    }

    if sftpService.isAuthorized() {
      print(">>> Refreshing sftp backup...")

      sftpService.fetchMetadata { [weak settings] in
        guard let settings = settings else { return }

        guard let metadata = try? $0.get()?.backup else {
          settings.value.backups[.sftp] = nil
          return
        }

        settings.value.backups[.sftp] = BackupModel(
          id: metadata.id,
          date: metadata.date,
          size: metadata.size
        )
      }
    }

    if dropboxService.isAuthorized() {
      print(">>> Refreshing dropbox backup...")

      dropboxService.downloadMetadata { [weak settings] in
        guard let settings = settings else { return }

        guard let metadata = try? $0.get() else {
          settings.value.backups[.dropbox] = nil
          return
        }

        settings.value.backups[.dropbox] = BackupModel(
          id: metadata.path,
          date: metadata.modifiedDate,
          size: metadata.size
        )
      }
    }

    driveService.isAuthorized { [weak settings] isAuthorized  in
      print(">>> Refreshing drive backup...")
      guard let settings = settings else { return }

      if isAuthorized {
        self.driveService.downloadMetadata {
          guard let metadata = try? $0.get() else { return }

          settings.value.backups[.drive] = BackupModel(
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
    print(">>> Did call performBackup(data)")

    guard let enabledService = settings.value.enabledService else {
      fatalError("Trying to backup but nothing is enabled")
    }

    let url = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent(UUID().uuidString)

    do {
      try data.write(to: url, options: .atomic)
    } catch {
      print(">>> Couldn't write to temp: \(error.localizedDescription)")
      return
    }

    switch enabledService {
    case .drive:
      print(">>> Performing upload on drive")
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
      print(">>> Performing upload on iCloud")
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
      print(">>> Performing upload on dropbox")
      dropboxService.uploadBackup(url) {
        switch $0 {
        case .success(let metadata):
          print(">>> Performed upload on dropbox: \(metadata)")

          self.settings.value.backups[.dropbox] = .init(
            id: metadata.path,
            date: metadata.modifiedDate,
            size: metadata.size
          )

          self.refreshBackups()
        case .failure(let error):
          print(error.localizedDescription)
        }
      }
    case .sftp:
      print(">>> Performing upload on sftp")
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
