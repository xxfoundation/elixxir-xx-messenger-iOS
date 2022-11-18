import Dependencies

private enum KeychainDependencyKey: DependencyKey {
  static let liveValue: KeychainManager = .live
  static let testValue: KeychainManager = .unimplemented
}

extension DependencyValues {
  public var keychain: KeychainManager {
    get { self[KeychainDependencyKey.self] }
    set { self[KeychainDependencyKey.self] = newValue }
  }
}
