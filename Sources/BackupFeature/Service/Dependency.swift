import Dependencies

private enum BackupServiceDependencyKey: DependencyKey {
  static let liveValue: BackupService = .init()
  static let testValue: BackupService = .init()
}

extension DependencyValues {
  public var backupService: BackupService {
    get { self[BackupServiceDependencyKey.self] }
    set { self[BackupServiceDependencyKey.self] = newValue }
  }
}
