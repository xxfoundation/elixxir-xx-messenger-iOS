import LocalAuthentication
import XCTestDynamicOverlay

public struct PermissionBiometrics {
  public var status: PermissionBiometricsStatus
  public var request: PermissionBiometricsRequest

  public static let live = PermissionBiometrics(
    status: .live,
    request: .live
  )
  public static let unimplemented = PermissionBiometrics(
    status: .unimplemented,
    request: .unimplemented
  )
}

public struct PermissionBiometricsStatus {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }

  public static let live = PermissionBiometricsStatus {
    var error: NSError?
    let context = LAContext()

    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) == true {
      return true
    } else {
      let tooManyAttempts = LAError.Code.biometryLockout.rawValue
      guard let error = error, error.code == tooManyAttempts else { return true }
      return false
    }
  }

  public static let unimplemented = PermissionBiometricsStatus(
    run: XCTUnimplemented("\(Self.self)")
  )
}

public struct PermissionBiometricsRequest {
  public var run: (@escaping (Bool) -> Void) -> Void

  public func callAsFunction(_ completion: @escaping (Bool) -> Void) -> Void {
    run(completion)
  }

  public static let live = PermissionBiometricsRequest { completion in
    let reason = "Authentication is required to use xx messenger"
    LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
      if let error {
        completion(false)
        return
      }

      completion(success)
    }
  }

  public static let unimplemented = PermissionBiometricsRequest(
    run: XCTUnimplemented("\(Self.self)")
  )
}
