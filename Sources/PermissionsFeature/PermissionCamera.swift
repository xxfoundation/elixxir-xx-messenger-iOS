import AVFoundation
import XCTestDynamicOverlay

public struct PermissionCamera {
  public var status: PermissionCameraStatus
  public var request: PermissionCameraRequest

  public static let live = PermissionCamera(
    status: .live,
    request: .live
  )
  public static let unimplemented = PermissionCamera(
    status: .unimplemented,
    request: .unimplemented
  )
}

public struct PermissionCameraStatus {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }

  public static let live = PermissionCameraStatus {
    AVCaptureDevice.authorizationStatus(for: .video) == .authorized
  }

  public static let unimplemented = PermissionCameraStatus(
    run: XCTUnimplemented("\(Self.self)")
  )
}

public struct PermissionCameraRequest {
  public var run: (@escaping (Bool) -> Void) -> Void

  public func callAsFunction(_ completion: @escaping (Bool) -> Void) -> Void {
    run(completion)
  }

  public static let live = PermissionCameraRequest {
    AVCaptureDevice.requestAccess(for: .video, completionHandler: $0)
  }

  public static let unimplemented = PermissionCameraRequest(
    run: XCTUnimplemented("\(Self.self)")
  )
}
