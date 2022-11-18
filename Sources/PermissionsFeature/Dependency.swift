import Dependencies

private enum PermissionsDependencyKey: DependencyKey {
  static let liveValue: PermissionsManager = .live
  static let testValue: PermissionsManager = .unimplemented
}

extension DependencyValues {
  public var permissions: PermissionsManager {
    get { self[PermissionsDependencyKey.self] }
    set { self[PermissionsDependencyKey.self] = newValue }
  }
}
