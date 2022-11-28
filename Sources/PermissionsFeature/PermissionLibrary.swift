import Photos
import XCTestDynamicOverlay

public struct PermissionLibrary {
  public var status: PermissionLibraryStatus
  public var request: PermissionLibraryRequest

  public static let live = PermissionLibrary(
    status: .live,
    request: .live
  )
  public static let unimplemented = PermissionLibrary(
    status: .unimplemented,
    request: .unimplemented
  )
}

public struct PermissionLibraryStatus {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }

  public static let live = PermissionLibraryStatus {
    PHPhotoLibrary.authorizationStatus() == .authorized
  }

  public static let unimplemented = PermissionLibraryStatus(
    run: XCTUnimplemented("\(Self.self)")
  )
}

public struct PermissionLibraryRequest {
  public var run: (@escaping (Bool) -> Void) -> Void

  public func callAsFunction(_ completion: @escaping (Bool) -> Void) -> Void {
    run(completion)
  }

  public static let live = PermissionLibraryRequest { completion in
    PHPhotoLibrary.requestAuthorization { completion($0 == .authorized) }
  }

  public static let unimplemented = PermissionLibraryRequest(
    run: XCTUnimplemented("\(Self.self)")
  )
}
