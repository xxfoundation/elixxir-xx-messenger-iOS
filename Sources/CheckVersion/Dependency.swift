import Dependencies

private enum CheckVersionDependencyKey: DependencyKey {
  static let liveValue: CheckVersion = .live()
  static let testValue: CheckVersion = .unimplemented
}

extension DependencyValues {
  public var checkVersion: CheckVersion {
    get { self[CheckVersionDependencyKey.self] }
    set { self[CheckVersionDependencyKey.self] = newValue }
  }
}
