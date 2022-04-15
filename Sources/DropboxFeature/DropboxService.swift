import UIKit
import Combine
import SwiftyDropbox

public struct DropboxService: DropboxInterface {
    private let didAuthorizeSubject = PassthroughSubject<Result<Bool, Error>, Never>()

    public init() {
        let path = Bundle.module.path(forResource: "Dropbox-Keys", ofType: "plist")
        let url = URL(fileURLWithPath: path!)
        let keys = try! NSDictionary(contentsOf: url, error: ())

        DropboxClientsManager.setupWithAppKey(keys["DROPBOX_APP_KEY"] as! String)
    }

    public func unlink() {
        DropboxClientsManager.unlinkClients()
    }

    public func isAuthorized() -> Bool {
        DropboxClientsManager.authorizedClient != nil
    }

    public func authorize(presenting controller: UIViewController) -> AnyPublisher<Result<Bool, Error>, Never> {
        let scopes = ["files.metadata.read", "files.content.read", "files.content.write"]

        return didAuthorizeSubject.handleEvents(receiveSubscription: { _ in
            let scopeRequest = ScopeRequest(scopeType: .user, scopes: scopes, includeGrantedScopes: false)

            DropboxClientsManager.authorizeFromControllerV2(
                UIApplication.shared,
                controller: controller,
                loadingStatusDelegate: nil,
                openURL: { (url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil) },
                scopeRequest: scopeRequest
            )
        }).first().eraseToAnyPublisher()
    }

    public func handleOpenUrl(_ url: URL) -> Bool {
        DropboxClientsManager.handleRedirectURL(url) {
            switch $0 {
            case .none:
                didAuthorizeSubject.send(.success(false))
            case .error(let oAuthError, _):
                didAuthorizeSubject.send(.failure(oAuthError))
            case .success:
                didAuthorizeSubject.send(.success(true))
            case .cancel:
                didAuthorizeSubject.send(.success(false))
            }
        }
    }

    public func downloadBackup(_ path: String, _ completion: @escaping (Result<Data, Error>) -> Void) {
        Task {
            do {
                guard try await folderExists() else { fatalError() }

                let data = try await fetchBackup()
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func uploadBackup(_ url: URL, _ completion: @escaping (Result<DropboxMetadata, Error>) -> Void) {
        Task {
            do {
                if try await !folderExists() {
                    try await createFolder()
                }

                let data = try Data(contentsOf: url)
                let metadata = try await upload(data: data)
                completion(.success(metadata))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func downloadMetadata(_ completion: @escaping (Result<DropboxMetadata?, Error>) -> Void) {
        Task {
            do {
                guard try await folderExists() else {
                    completion(.success(nil))
                    return
                }

                let metadata = try await fetchMetadata()
                completion(.success(metadata))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

extension DropboxService {
    private func folderExists() async throws -> Bool {
        guard let client = DropboxClientsManager.authorizedClient else { fatalError() }

        return try await withCheckedThrowingContinuation { continuation in
            client.files.listFolder(path: "/backup")
                .response { result, error in
                if let error = error {
                    if case .routeError(_, _, _, _) = error as CallError {
                        continuation.resume(returning: false)
                        return
                    }

                    let err = NSError(domain: error.description, code: 0)
                    continuation.resume(throwing: err)
                    return
                }

                continuation.resume(returning: result != nil)
            }
        }
    }

    private func createFolder() async throws {
        guard let client = DropboxClientsManager.authorizedClient else { fatalError() }

        return try await withCheckedThrowingContinuation { continuation in
            client.files.createFolderV2(path: "/backup")
                .response { _, error in
                if let error = error {
                    let err = NSError(domain: error.description, code: 0)
                    continuation.resume(throwing: err)
                    return
                }

                continuation.resume(returning: ())
            }
        }
    }

    private func fetchMetadata() async throws -> DropboxMetadata? {
        guard let client = DropboxClientsManager.authorizedClient else { fatalError() }

        return try await withCheckedThrowingContinuation { continuation in
            client.files.getMetadata(path: "/backup/backup.xxm")
                .response { response, error in
                if let error = error {
                    let err = NSError(domain: error.description, code: 0)
                    continuation.resume(throwing: err)
                    return
                }

                if let result = response as? Files.FileMetadata {
                    let size = Float(result.size)
                    let modifiedDate = result.serverModified
                    continuation.resume(returning: .init(
                        size: size,
                        path: "/backup/backup.xxm",
                        modifiedDate: modifiedDate
                    ))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private func fetchBackup() async throws -> Data {
        guard let client = DropboxClientsManager.authorizedClient else { fatalError() }

        return try await withCheckedThrowingContinuation { continuation in
            client.files.download(path: "/backup/backup.xxm")
                .response(completionHandler: { response, error in
                if let error = error {
                    let err = NSError(domain: error.description, code: 0)
                    continuation.resume(throwing: err)
                    return
                }

                if let response = response {
                    continuation.resume(returning: response.1)
                }
            })
        }
    }

    private func upload(data: Data) async throws -> DropboxMetadata {
        guard let client = DropboxClientsManager.authorizedClient else { fatalError() }

        return try await withCheckedThrowingContinuation { continuation in
            client.files.upload(path: "/backup/backup.xxm", mode: .overwrite, input: data)
                .response { response, error in
                    if let error = error {
                        let err = NSError(domain: error.description, code: 0)
                        continuation.resume(throwing: err)
                        return
                    }

                    if let response = response {
                        continuation.resume(returning: .init(
                            size: Float(response.size),
                            path: response.pathLower!,
                            modifiedDate: response.serverModified
                        ))
                    }
                }
        }
    }
}
