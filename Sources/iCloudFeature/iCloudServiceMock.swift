import Foundation

public struct iCloudServiceMock: iCloudInterface {
    public init() {
        // TODO
    }

    public func openSettings() {
        // TODO
    }

    public func isAuthorized() -> Bool {
        true
    }

    public func downloadBackup(
        _: String,
        _: @escaping (Result<Data, Error>) -> Void
    ) {
        // TODO
    }

    public func uploadBackup(
        _: URL,
        _: @escaping (Result<iCloudMetadata, Error>) -> Void
    ) {
        // TODO
    }

    public func downloadMetadata(
        _ completion: @escaping (Result<iCloudMetadata?, Error>) -> Void
    ) {
        completion(.success(.init(
            path: "/",
            size: 1230000000.0,
            modifiedDate: Date()
        )))
    }
}
