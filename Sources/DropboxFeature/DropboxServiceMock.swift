import UIKit
import Combine

public struct DropboxServiceMock: DropboxInterface {
    public init() {}

    public func unlink() {}

    public func isAuthorized() -> Bool { true }

    public func handleOpenUrl(_ url: URL) -> Bool { true }

    public func didFinishAuthFlow(withError: String?) {}

    public func downloadBackup(_: String, _: @escaping (Result<Data, Error>) -> Void) {}

    public func uploadBackup(_: URL, _: @escaping (Result<DropboxMetadata, Error>) -> Void) {}

    public func downloadMetadata(_: @escaping (Result<DropboxMetadata?, Error>) -> Void) {}

    public func authorize(presenting: UIViewController) -> AnyPublisher<Result<Bool, Error>, Never> { fatalError() }
}
