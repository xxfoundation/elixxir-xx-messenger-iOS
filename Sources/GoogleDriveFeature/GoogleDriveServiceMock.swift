import UIKit

public final class GoogleDriveServiceMock: GoogleDriveInterface {
    public init() {}

    public func isAuthorized(_ completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    public func uploadBackup(_: URL, _ completion: @escaping (Result<GoogleDriveMetadata, Error>) -> Void) {
        completion(.success(.init(size: 23.toBytes(), identifier: "", modifiedDate: Date())))
    }

    public func downloadMetadata(_ completion: @escaping (Result<GoogleDriveMetadata?, Error>) -> Void) {
        completion(.success(.init(size: 23.toBytes(), identifier: "", modifiedDate: Date())))
    }

    public func authorize(presenting: UIViewController, _ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    public func downloadBackup(
        _: String,
        progressCallback: @escaping (Float) -> Void,
        _ completion: @escaping (Result<Data, Error>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { progressCallback(3.toBytes()) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { progressCallback(7.toBytes()) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { progressCallback(12.toBytes()) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { progressCallback(15.toBytes()) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { progressCallback(16.toBytes()) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { progressCallback(19.toBytes()) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) { progressCallback(22.toBytes()) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { completion(.success(Data())) }
    }
}

private extension Int {
    func toBytes() -> Float { Float(self) * 1000000.0 }
}
