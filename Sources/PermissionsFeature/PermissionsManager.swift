public struct PermissionsManager {
  public var push: PermissionPush
  public var camera: PermissionCamera
  public var library: PermissionLibrary
  public var microphone: PermissionMicrophone
  public var biometrics: PermissionBiometrics

  public static let live = PermissionsManager(
    push: .live,
    camera: .live,
    library: .live,
    microphone: .live,
    biometrics: .live
  )
  public static let unimplemented = PermissionsManager(
    push: .unimplemented,
    camera: .unimplemented,
    library: .unimplemented,
    microphone: .unimplemented,
    biometrics: .unimplemented
  )
}
