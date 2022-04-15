import UIKit
import GoogleSignIn
import GTMSessionFetcherFull
import GTMSessionFetcherCore
import GoogleAPIClientForREST_Drive

public final class GoogleDriveService: GoogleDriveInterface {
    private static let scopeFile = "https://www.googleapis.com/auth/drive.file"
    private static let scopeAppData = "https://www.googleapis.com/auth/drive.appdata"

    var user: GIDGoogleUser?

    let service: GTLRDriveService = {
        let service = GTLRDriveService()

        let path = Bundle.module.path(forResource: "GoogleDrive-Keys", ofType: "plist")
        let url = URL(fileURLWithPath: path!)
        let keys = try! NSDictionary(contentsOf: url, error: ())

        service.apiKey = keys["DRIVE_API_KEY"] as? String
        return service
    }()

    public init() {}

    public func isAuthorized(_ completion: @escaping (Bool) -> Void) {
        guard GIDSignIn.sharedInstance.hasPreviousSignIn() else {
            return completion(false)
        }

        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            guard let user = user, let scopes = user.grantedScopes, error == nil else {
                return completion(false)
            }

            self.user = user
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            completion(scopes.contains(GoogleDriveService.scopeFile) && scopes.contains(GoogleDriveService.scopeAppData))
        }
    }

    public func authorize(
        presenting controller: UIViewController,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            guard let self = self else { return }

            guard error == nil else {
                self.signIn(presenting: controller) {
                    switch $0 {
                    case .success:
                        self.authorizeDrive(controller: controller, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }

                return
            }

            guard let user = user else { fatalError() }

            self.user = user
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            self.authorizeDrive(controller: controller, completion: completion)
        }
    }

    public func downloadMetadata(_ completion: @escaping (Result<GoogleDriveMetadata?, Error>) -> Void) {
        Task {
            do {
                guard let folder = try await fetchFolder() else {
                    completion(.success(nil))
                    return
                }

                _ = try await listFiles(on: folder)

                let backup = try await fetchBackup(at: folder)
                completion(.success(backup))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func downloadBackup(
        _ backup: String,
        progressCallback: @escaping (Float) -> Void,
        _ completion: @escaping (Result<Data, Error>) -> Void
    ) {
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: backup)
        service.executeQuery(query) { _, file, error in
            guard error == nil else {
                print("Error on line #\(#line): \(error!.localizedDescription)")
                return completion(.failure(error!))
            }

            guard let data = (file as? GTLRDataObject)?.data else {
                print("Error on line #\(#line)")
                return completion(.failure(NSError()))
            }

            completion(.success(data))
        }
    }

    public func uploadBackup(
        _ file: URL,
        _ completion: @escaping (Result<GoogleDriveMetadata, Error>) -> Void
    ) {
        Task {
            do {
                var folder = try await fetchFolder()
                if folder == nil { folder = try await createFolder() }
                let metadata = try await uploadFile(file, to: folder!)
                let listMetadata = try await listFiles(on: folder!)
                try await cleanup(listMetadata)
                completion(.success(metadata))
            } catch {
                print("Error on line #\(#line): \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

extension GoogleDriveService {
    private func authorizeDrive(
        controller: UIViewController,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        if let user = user,
           let scopes = user.grantedScopes,
           scopes.contains(GoogleDriveService.scopeFile),
           scopes.contains(GoogleDriveService.scopeAppData) {
            return completion(.success(()))
        }

        GIDSignIn.sharedInstance.addScopes(
            [GoogleDriveService.scopeFile, GoogleDriveService.scopeAppData],
            presenting: controller, callback: { user, error in
                guard error == nil else {
                    print("Error on line #\(#line): \(error!.localizedDescription)")
                    return completion(.failure(error!))
                }

                guard let user = user else { fatalError() }
                self.user = user
                completion(.success(()))
            }
        )
    }

    private func signIn(
        presenting controller: UIViewController,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        GIDSignIn.sharedInstance.signIn(
            with: GIDConfiguration(clientID: "662236151640-30i07ubg6ukodg15u0bnpk322p030u3j.apps.googleusercontent.com"),
            presenting: controller,
            callback: { user, error in
                guard error == nil else {
                    print("Error on line #\(#line): \(error!.localizedDescription)")
                    return completion(.failure(error!))
                }

                guard let user = user else { fatalError() }

                self.user = user
                self.service.authorizer = user.authentication.fetcherAuthorizer()
                completion(.success(()))
            }
        )
    }

    private func fetchFolder() async throws -> String? {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType = 'application/vnd.google-apps.folder' and name = 'backup'"
        query.spaces = "appDataFolder"
        query.fields = "nextPageToken, files(id, name)"

        return try await withCheckedThrowingContinuation { continuation in
            service.executeQuery(query) { _, result, error in
                if let error = error {
                    print("Error on line #\(#line): \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }

                let item = (result as? GTLRDrive_FileList)?.files?.first
                continuation.resume(returning: item?.identifier)
            }
        }
    }

    private func fetchBackup(at folder: String) async throws -> GoogleDriveMetadata? {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "'\(folder)' in parents and name = 'backup.xxm'"
        query.spaces = "appDataFolder"
        query.fields = "nextPageToken, files(id, size, name, modifiedTime)"

        return try await withCheckedThrowingContinuation { continuation in
            service.executeQuery(query) { _, result, error in
                if let error = error {
                    print("Error on line #\(#line): \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }

                var metadata: GoogleDriveMetadata? = nil

                if let file = (result as? GTLRDrive_FileList)?.files?.first,
                   let size = file.size,
                   let id = file.identifier,
                   let date = file.modifiedTime?.date {
                    metadata = GoogleDriveMetadata(size: size.floatValue, identifier: id, modifiedDate: date)
                }

                continuation.resume(returning: metadata)
            }
        }
    }

    private func createFolder() async throws -> String {
        let file = GTLRDrive_File()
        file.name = "backup"
        file.parents = ["appDataFolder"]
        file.mimeType = "application/vnd.google-apps.folder"

        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: nil)

        return try await withCheckedThrowingContinuation { continuation in
            service.executeQuery(query) { _, result, error in
                if let error = error {
                    print("Error on line #\(#line): \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }

                guard let identifier = (result as? GTLRDrive_File)?.identifier else {
                    let errorTitle = "Couldn't create backup folder but no error was passed (?)"
                    let error = NSError(domain: errorTitle, code: 0, userInfo: [NSLocalizedDescriptionKey: errorTitle])
                    print("Error on line #\(#line): \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: identifier)
            }
        }
    }

    private func uploadFile(
        _ fileURL: URL,
        to folder: String
    ) async throws -> GoogleDriveMetadata {

        let file = GTLRDrive_File()
        file.name = "backup.xxm"
        file.parents = [folder]
        file.mimeType = "application/octet-stream"

        let params = GTLRUploadParameters(fileURL: fileURL, mimeType: file.mimeType!)
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: params)
        query.fields = "id, size, modifiedTime"

        return try await withCheckedThrowingContinuation { continuation in
            service.executeQuery(query) { _, result, error in
                if let error = error {
                    print("Error on line #\(#line): \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }

                guard let driveFile = (result as? GTLRDrive_File),
                      let size = driveFile.size,
                      let id = driveFile.identifier,
                      let date = driveFile.modifiedTime?.date else {
                    let errorTitle = "Couldn't upload file but no error was passed (?)"
                    let error = NSError(domain: errorTitle, code: 0, userInfo: [NSLocalizedDescriptionKey: errorTitle])
                    print("Error on line #\(#line): \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: .init(size: size.floatValue, identifier: id, modifiedDate: date))
            }
        }
    }

    private func listFiles(on folder: String) async throws -> [GoogleDriveMetadata] {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "'\(folder)' in parents"
        query.spaces = "appDataFolder"
        query.fields = "nextPageToken, files(id, modifiedTime, size, name)"

        return try await withCheckedThrowingContinuation { continuation in
            service.executeQuery(query) { _, result, error in
                if let error = error {
                    print("Error on line #\(#line): \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }

                guard let files = (result as? GTLRDrive_FileList)?.files else {
                    continuation.resume(returning: [])
                    return
                }

                let metadataList = files.compactMap(GoogleDriveMetadata.init(withDriveFile:))
                continuation.resume(returning: metadataList)
            }
        }
    }

    private func cleanup(_ files: [GoogleDriveMetadata]) async throws {
        let latestBackup = files.max { $0.modifiedDate < $1.modifiedDate }
        let identifiers = files.filter { $0 != latestBackup }.map(\.identifier)
        let query = GTLRBatchQuery(queries: identifiers.map(GTLRDriveQuery_FilesDelete.query(withFileId:)))

        return try await withCheckedThrowingContinuation { continuation in
            service.executeQuery(query) { _, _, error in
                if let error = error {
                    print("Error on line #\(#line): \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: ())
            }
        }
    }
}
