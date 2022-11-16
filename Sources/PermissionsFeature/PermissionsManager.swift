public struct PermissionsManager {
  public var camera: PermissionCamera
  public var library: PermissionLibrary
  public var microphone: PermissionMicrophone
  public var biometrics: PermissionBiometrics

  public static let live = PermissionsManager(
    camera: .live,
    library: .live,
    microphone: .live,
    biometrics: .live
  )
  public static let unimplemented = PermissionsManager(
    camera: .unimplemented,
    library: .unimplemented,
    microphone: .unimplemented,
    biometrics: .unimplemented
  )
}

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
