import Foundation

public protocol iCloudInterface {
    func openSettings()

    func isAuthorized() -> Bool

    func downloadMetadata(_: @escaping (Result<iCloudMetadata?, Error>) -> Void)

    func uploadBackup(_: URL, _: @escaping (Result<iCloudMetadata, Error>) -> Void)

    func downloadBackup(_: String, _: @escaping (Result<Data, Error>) -> Void)
}
