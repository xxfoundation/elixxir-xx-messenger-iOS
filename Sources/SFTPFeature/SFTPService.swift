import UIKit
import Shout
import Models
import Combine
import Keychain
import Foundation
import Presentation
import DependencyInjection

public typealias SFTPFetchResult = (Result<RestoreSettings?, Error>) -> Void
public typealias SFTPAuthorizationParams = (UIViewController, () -> Void)

public struct SFTPService {
    public var isAuthorized: () -> Bool
    public var uploadBackup: (URL) throws -> Void
    public var downloadBackup: (String) throws -> Void
    public var fetchMetadata: (SFTPFetchResult) -> Void
    public var authenticate: (String, String, String) throws -> Void
    public var authorizeFlow: (SFTPAuthorizationParams) -> Void
}

public extension SFTPService {
    static var mock = SFTPService(
        isAuthorized: {
            print("^^^ Requested auth status on sftp service")
            return true
        },
        uploadBackup: { url in
            print("^^^ Requested upload on sftp service")
            print("^^^ URL path: \(url.path)")
        },
        downloadBackup: { path in
            print("^^^ Requested backup download on sftp service.")
            print("^^^ Path: \(path)")
        },
        fetchMetadata: { completion in
            print("^^^ Requested backup metadata on sftp service.")
            completion(.success(nil))
        },
        authenticate: { host, username, password in
            print("^^^ Requested authentication on sftp service.")
            print("^^^ Host: \(host)")
            print("^^^ Username: \(username)")
            print("^^^ Password: \(password)")
        },
        authorizeFlow: { (_, completion) in
            print("^^^ Requested authorizing flow on sftp service.")
            completion()
        }
    )

    static var live = SFTPService(
        isAuthorized: {
            if let keychain = try? DependencyInjection.Container.shared.resolve() as KeychainHandling,
               let pwd = try? keychain.get(key: .pwd),
               let host = try? keychain.get(key: .host),
               let username = try? keychain.get(key: .username) {
                return true
            }

            return false
        },
        uploadBackup: { url in
            let keychain = try DependencyInjection.Container.shared.resolve() as KeychainHandling
            let host = try keychain.get(key: .host)
            let password = try keychain.get(key: .pwd)
            let username = try keychain.get(key: .username)

            let ssh = try SSH(host: host!, port: 22)
            try ssh.authenticate(username: username!, password: password!)
            let sftp = try ssh.openSftp()

            try sftp.upload(localURL: url, remotePath: "backup/backup.xxm")
        },
        downloadBackup: { path in
            let keychain = try DependencyInjection.Container.shared.resolve() as KeychainHandling
            let host = try keychain.get(key: .host)
            let password = try keychain.get(key: .pwd)
            let username = try keychain.get(key: .username)

            let ssh = try SSH(host: host!, port: 22)
            try ssh.authenticate(username: username!, password: password!)
            let sftp = try ssh.openSftp()

            let temp = NSTemporaryDirectory()
            try sftp.download(remotePath: path, localURL: URL(string: temp)!)
            print(FileManager.default.fileExists(atPath: temp))
        },
        fetchMetadata: { completion in
            do {
                let keychain = try DependencyInjection.Container.shared.resolve() as KeychainHandling
                let host = try keychain.get(key: .host)
                let password = try keychain.get(key: .pwd)
                let username = try keychain.get(key: .username)

                let ssh = try SSH(host: host!, port: 22)
                try ssh.authenticate(username: username!, password: password!)
                let sftp = try ssh.openSftp()

                if let files = try? sftp.listFiles(in: "backup"),
                   let backup = files.filter({ file in file.0 == "backup.xxm" }).first {
                    completion(.success(.init(
                        backup: .init(
                            id: "backup/backup.xxm",
                            date: backup.value.lastModified,
                            size: Float(backup.value.size)
                        ),
                        cloudService: .sftp
                    )))

                    return
                }

                completion(.success(nil))
            } catch {
                completion(.failure(error))
            }
        },
        authenticate: { host, username, password in
            let ssh = try SSH(host: host, port: 22)
            try ssh.authenticate(username: username, password: password)
            let sftp = try ssh.openSftp()

            let keychain = try DependencyInjection.Container.shared.resolve() as KeychainHandling
            try keychain.store(key: .host, value: host)
            try keychain.store(key: .pwd, value: password)
            try keychain.store(key: .username, value: username)
        },
        authorizeFlow: { controller, completion in
            var pushPresenter: Presenting = PushPresenter()
            pushPresenter.present(SFTPController(completion), from: controller)
        }
    )
}
