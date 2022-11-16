import AVFoundation
import XCTestDynamicOverlay

public struct PermissionMicrophone {
  public var status: PermissionMicrophoneStatus
  public var request: PermissionMicrophoneRequest

  public static let live = PermissionMicrophone(
    status: .live,
    request: .live
  )
  public static let unimplemented = PermissionMicrophone(
    status: .unimplemented,
    request: .unimplemented
  )
}

public struct PermissionMicrophoneRequest {
  public var run: (@escaping (Bool) -> Void) -> Void

  public func callAsFunction(_ completion: @escaping (Bool) -> Void) -> Void {
    run(completion)
  }
}

extension PermissionMicrophoneRequest {
  public static let live = PermissionMicrophoneRequest {
    AVAudioSession.sharedInstance().requestRecordPermission($0)
  }
}

extension PermissionMicrophoneRequest {
  public static let unimplemented = PermissionMicrophoneRequest(
    run: XCTUnimplemented("\(Self.self)")
  )
}

public struct PermissionMicrophoneStatus {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension PermissionMicrophoneStatus {
  public static let live = PermissionMicrophoneStatus {
    AVAudioSession.sharedInstance().recordPermission == .granted
  }
}

extension PermissionMicrophoneStatus {
  public static let unimplemented = PermissionMicrophoneStatus(
    run: XCTUnimplemented("\(Self.self)")
  )
}
