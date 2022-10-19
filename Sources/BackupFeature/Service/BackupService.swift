import UIKit
import Models
import Combine
import XXClient
import Defaults
import NetworkMonitor
import XXMessengerClient
import DependencyInjection

import CloudFiles
import CloudFilesSFTP
import CloudFilesDrive
import CloudFilesICloud
import CloudFilesDropbox

import KeychainAccess

public enum BackupProvider: Equatable, Codable {
  case sftp
  case drive
  case icloud
  case dropbox
}

public final class BackupService {
  @Dependency var messenger: Messenger
  @Dependency var networkManager: NetworkMonitoring

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

  public func setupSFTP(host: String, username: String, password: String) {
    managers[.sftp] = .sftp(
      host: host,
      username: username,
      password: password,
      fileName: "backup.xxm"
    )
    refreshBackups()
    refreshConnections()
  }
}

extension BackupService {
  public func stopBackups() {
    if messenger.isBackupRunning() == true {
      try! messenger.stopBackup()
    }
  }

  public func initializeBackup(passphrase: String) {
    try! messenger.startBackup(
      password: passphrase,
      params: .init(username: username!)
    )
  }

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

    guard let data = try? Data(contentsOf: fileUrl) else { return }
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

  public func toggle(service: BackupProvider, enabling: Bool) {
    settings.value.enabledService = enabling ? service : nil
  }

  public func authorize(
    service: BackupProvider,
    presenting screen: UIViewController
  ) {
    do {
      try managers[service]?.link(screen) { [weak self] in
        guard let self else { return }
        switch $0 {
        case .success:
          self.refreshConnections()
          self.refreshBackups()
        case .failure(let error):
          print(error.localizedDescription)
        }
      }
    } catch {
      print(error.localizedDescription)
    }
  }
}

extension BackupService {
  private func refreshConnections() {
    managers.forEach { provider, manager in
      if manager.isLinked() && !settings.value.connectedServices.contains(provider) {
        settings.value.connectedServices.insert(provider)
      } else if !manager.isLinked() && settings.value.connectedServices.contains(provider) {
        settings.value.connectedServices.remove(provider)
      }
    }
  }

  private func refreshBackups() {
    managers.forEach { provider, manager in
      if manager.isLinked() {
        do {
          try manager.fetch { [weak self] in
            guard let self else { return }

            switch $0 {
            case .success(let metadata):
              self.settings.value.backups[provider] = metadata
            case .failure(let error):
              print(error.localizedDescription)
            }
          }
        } catch {
          print(error.localizedDescription)
        }
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
      print(">>> Couldn't write to temp: \(error.localizedDescription)")
      return
    }

    if enabledService == .sftp {
      let keychain = Keychain(service: "SFTP-XXM")
      guard let host = try? keychain.get("host"),
            let password = try? keychain.get("pwd"),
            let username = try? keychain.get("username") else {
        fatalError("Tried to perform an sftp backup but its not configured")
      }

      managers[.sftp] = .sftp(
        host: host,
        username: username,
        password: password,
        fileName: "backup.xxm"
      )
    }

    if let manager = managers[enabledService] {
      do {
        try manager.upload(data) { [weak self] in
          guard let self else { return }

          switch $0 {
          case .success(let metadata):
            self.settings.value.backups[enabledService] = .init(
              size: metadata.size,
              lastModified: metadata.lastModified
            )
          case .failure(let error):
            print(error.localizedDescription)
          }
        }
      } catch {
        print(error.localizedDescription)
      }
    }
  }
}
