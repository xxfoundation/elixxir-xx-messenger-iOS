import UIKit
import FilesProvider

public struct iCloudService: iCloudInterface {
    private let documentsProvider = CloudFileProvider(containerId: "iCloud.xxm-cloud", scope: .data)

    public init() {}

    public func isAuthorized() -> Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    public func openSettings() {
        if let url = URL(string: "App-Prefs:root=CASTLE"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    public func downloadMetadata(_ completion: @escaping (Result<iCloudMetadata?, Error>) -> Void) {
        guard let documentsProvider = documentsProvider else { fatalError() }

        documentsProvider.contentsOfDirectory(path: "/", completionHandler: { contents, error in
            guard error == nil else {
                print(">>> [iCloud] downloadMetadata got error: \(error!.localizedDescription)")
                completion(.failure(error!))
                return
            }

            print(contents)

            if let file = contents.first(where: { $0.name == "backup.xxm" }) {
                completion(.success(.init(
                    path: file.path,
                    size: Float(file.size),
                    modifiedDate: file.modifiedDate!
                )))
            } else {
                completion(.success(nil))
            }
        })
    }

    public func uploadBackup(_ url: URL, _ completion: @escaping (Result<iCloudMetadata, Error>) -> Void) {
        guard let documentsProvider = documentsProvider else { fatalError() }

        do {
            let data = try Data(contentsOf: url)

            documentsProvider.writeContents(path: "backup.xxm", contents: data, overwrite: true) { error in
                guard error == nil else {
                    print(">>> [iCloud] uploadBackup got error: \(error!.localizedDescription)")
                    completion(.failure(error!))
                    return
                }

                completion(.success(.init(
                    path: "backup.xxm",
                    size: Float(data.count),
                    modifiedDate: Date()
                )))
            }
        } catch {
            completion(.failure(error))
        }
    }

    public func downloadBackup(
        _ path: String,
        _ completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let documentsProvider = documentsProvider else { fatalError() }

        documentsProvider.contents(path: path, completionHandler: { contents, error in
            guard error == nil else {
                print(">>> [iCloud] downloadBackup got error: \(error!.localizedDescription)")
                completion(.failure(error!))
                return
            }

            if let contents = contents {
                completion(.success(contents))
            } else {
                completion(.failure(NSError(domain: "Backup file is invalid", code: 0)))
            }
        })
    }
}
