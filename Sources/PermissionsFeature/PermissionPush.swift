import UserNotifications
import XCTestDynamicOverlay

public struct PermissionPush {
  public var status: PermissionPushStatus
  public var request: PermissionPushRequest

  public static let live = PermissionPush(
    status: .live,
    request: .live
  )
  public static let unimplemented = PermissionPush(
    status: .unimplemented,
    request: .unimplemented
  )
}

public struct PermissionPushRequest {
  public var run: (@escaping (Bool) -> Void) -> Void

  public func callAsFunction(_ completion: @escaping (Bool) -> Void) -> Void {
    run(completion)
  }
}

extension PermissionPushRequest {
  public static let live = PermissionPushRequest { completion in
    let current = UNUserNotificationCenter.current()
    current.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if error != nil {
        completion(false)
        return
      }
      completion(granted)
    }
  }
}

extension PermissionPushRequest {
  public static let unimplemented = PermissionPushRequest(
    run: XCTUnimplemented("\(Self.self)")
  )
}

public struct PermissionPushStatus {
  public var run: (@escaping (Bool) -> Void) -> Void

  public func callAsFunction(_ completion: @escaping (Bool) -> Void) -> Void {
    run(completion)
  }
}

extension PermissionPushStatus {
  public static let live = PermissionPushStatus { completion in
    let current = UNUserNotificationCenter.current()
    current.getNotificationSettings {
      completion($0.authorizationStatus == .authorized)
    }
  }
}

extension PermissionPushStatus {
  public static let unimplemented = PermissionPushStatus(
    run: XCTUnimplemented("\(Self.self)")
  )
}
