import UIKit

public protocol GoogleDriveInterface {
    func isAuthorized(_: @escaping (Bool) -> Void)

    func downloadMetadata(_: @escaping (Result<GoogleDriveMetadata?, Error>) -> Void)

    func uploadBackup(_: URL, _: @escaping (Result<GoogleDriveMetadata, Error>) -> Void)

    func authorize(presenting: UIViewController, _: @escaping (Result<Void, Error>) -> Void)

    func downloadBackup(_: String, progressCallback: @escaping (Float) -> Void, _: @escaping (Result<Data, Error>) -> Void)
}
