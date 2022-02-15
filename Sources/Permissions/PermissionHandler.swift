import Photos
import AVFoundation
import LocalAuthentication

public protocol PermissionHandling {
    var isCameraAllowed: Bool { get }
    var isPhotosAllowed: Bool { get }
    var isMicrophoneAllowed: Bool { get }
    var isBiometricsAvailable: Bool { get }

    func requestPhotos(_: @escaping (Bool) -> Void)
    func requestCamera(_: @escaping (Bool) -> Void)
    func requestMicrophone(_: @escaping (Bool) -> Void)
    func requestBiometrics(_: @escaping (Result<Bool, Error>) -> Void)
}

public struct PermissionHandler: PermissionHandling {
    public init() {}

    public var isMicrophoneAllowed: Bool {
        AVAudioSession.sharedInstance().recordPermission == .granted
    }

    public var isCameraAllowed: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized
    }

    public var isPhotosAllowed: Bool {
        PHPhotoLibrary.authorizationStatus() == .authorized
    }

    public var isBiometricsAvailable: Bool {
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

    public func requestBiometrics(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        let reason = "Authentication is required to use xx messenger"
        LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason, reply: { success, error in
            guard let error = error else {
                completion(.success(success))
                return
            }

            completion(.failure(error))
        })
    }

    public func requestCamera(_ completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
    }

    public func requestMicrophone(_ completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission(completion)
    }

    public func requestPhotos(_ completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { completion($0 == .authorized) }
    }
}
