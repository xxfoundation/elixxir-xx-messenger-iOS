import UIKit
import Combine

public protocol DropboxInterface {
    func isAuthorized() -> Bool

    func unlink()

    func handleOpenUrl(_ url: URL) -> Bool

    func downloadBackup(_: String, _: @escaping (Result<Data, Error>) -> Void)

    func uploadBackup(_: URL, _: @escaping (Result<DropboxMetadata, Error>) -> Void)

    func downloadMetadata(_: @escaping (Result<DropboxMetadata?, Error>) -> Void)

    func authorize(presenting: UIViewController) -> AnyPublisher<Result<Bool, Error>, Never>
}
