import Foundation
import CloudFiles

public struct BackupSettings: Equatable, Codable {
  public var wifiOnlyBackup: Bool
  public var automaticBackups: Bool
  public var enabledService: BackupProvider?
  public var connectedServices: Set<BackupProvider>
  public var backups: [BackupProvider: Fetch.Metadata]

  public init(
    wifiOnlyBackup: Bool = false,
    automaticBackups: Bool = false,
    enabledService: BackupProvider? = nil,
    connectedServices: Set<BackupProvider> = [],
    backups: [BackupProvider: Fetch.Metadata] = [:]
  ) {
    self.wifiOnlyBackup = wifiOnlyBackup
    self.automaticBackups = automaticBackups
    self.enabledService = enabledService
    self.connectedServices = connectedServices
    self.backups = backups
  }

  public func toData() -> Data {
    (try? PropertyListEncoder().encode(self)) ?? Data()
  }

  public init(fromData data: Data?) {
    if let data = data, let settings = try? PropertyListDecoder().decode(BackupSettings.self, from: data) {
      self.init(
        wifiOnlyBackup: settings.wifiOnlyBackup,
        automaticBackups: settings.automaticBackups,
        enabledService: settings.enabledService,
        connectedServices: settings.connectedServices,
        backups: settings.backups
      )
    } else {
      self.init(
        wifiOnlyBackup: false,
        automaticBackups: true,
        enabledService: nil,
        connectedServices: [],
        backups: [:]
      )
    }
  }
}
