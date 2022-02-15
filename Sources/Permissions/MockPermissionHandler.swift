import AVFoundation

public class MockPermissionHandler: PermissionHandling {
    private var cameraStatus = false
    private var photosStatus = false
    private var biometricsStatus = false
    private var microphoneStatus = false

    public init() {}

    public var isCameraAllowed: Bool { cameraStatus }

    public var isPhotosAllowed: Bool { photosStatus }

    public var isMicrophoneAllowed: Bool { microphoneStatus }

    public var isBiometricsAvailable: Bool { biometricsStatus }

    public func requestBiometrics(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        biometricsStatus = true
        completion(.success(true))
    }

    public func requestCamera(_ completion: @escaping (Bool) -> Void) {
        cameraStatus = true
        completion(true)
    }

    public func requestMicrophone(_ completion: @escaping (Bool) -> Void) {
        microphoneStatus = true
        completion(true)
    }

    public func requestPhotos(_ completion: @escaping (Bool) -> Void) {
        photosStatus = true
        completion(true)
    }
}
