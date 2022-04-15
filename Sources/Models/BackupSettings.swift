import Foundation

public struct BackupSettings: Equatable, Codable {
    public var wifiOnlyBackup: Bool
    public var automaticBackups: Bool
    public var enabledService: CloudService?
    public var connectedServices: Set<CloudService>
    public var backups: [CloudService: Backup]

    public init(
        wifiOnlyBackup: Bool = false,
        automaticBackups: Bool = false,
        enabledService: CloudService? = nil,
        connectedServices: Set<CloudService> = [],
        backups: [CloudService: Backup] = [:]
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

    public init(fromData data: Data) {
        let settings = try? PropertyListDecoder().decode(BackupSettings.self, from: data)
        self.init(
            wifiOnlyBackup: settings?.wifiOnlyBackup ?? false,
            automaticBackups: settings?.automaticBackups ?? false,
            enabledService: settings?.enabledService,
            connectedServices: settings?.connectedServices ?? [],
            backups: settings?.backups ?? [:]
        )
    }
}

public struct RestoreSettings {
    public var backup: Backup?
    public var cloudService: CloudService

    public init(
        backup: Backup? = nil,
        cloudService: CloudService
    ) {
        self.backup = backup
        self.cloudService = cloudService
    }
}
