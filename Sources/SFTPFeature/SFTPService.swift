import Shout
import Models
import Keychain
import Foundation
import DependencyInjection

public typealias SFTPAuthParams = (String, String, String)
public typealias SFTPFetchResult = (Result<RestoreSettings?, Error>) -> Void
public typealias SFTPFetchParams = (SFTPAuthParams, SFTPFetchResult)

public struct SFTPService {
    public var isAuthorized: () -> Bool
    public var upload: (URL) throws -> Void
    public var fetch: (SFTPFetchParams) -> Void
    public var download: (String) throws -> Void
    public var justAuthenticate: (SFTPAuthParams) throws -> Void
}

public extension SFTPService {
    static var mock = SFTPService(
        isAuthorized: {
            print("^^^ Requested auth status on sftp service")
            return true
        },
        upload: { url in
            print("^^^ Requested upload on sftp service")
            print("^^^ URL path: \(url.path)")
        },
        fetch: { (authParams, completion) in
            print("^^^ Requested backup metadata on sftp service.")
            print("^^^ Host: \(authParams.0)")
            print("^^^ Username: \(authParams.1)")
            print("^^^ Password: \(authParams.2)")
            completion(.success(nil))
        },
        download: { path in
            print("^^^ Requested backup download on sftp service.")
            print("^^^ Path: \(path)")
        },
        justAuthenticate: { host, username, password in
            print("^^^ Requested to authenticate on sftp service")
            print("^^^ Host: \(host)")
            print("^^^ Username: \(username)")
            print("^^^ Password: \(password)")
        })

    static var live = SFTPService(
        isAuthorized: {
            if let keychain = try? DependencyInjection.Container.shared.resolve() as KeychainHandling,
               let pwd = try? keychain.get(key: .pwd),
               let host = try? keychain.get(key: .host),
               let username = try? keychain.get(key: .username) {
                return true
            } else {
                return false
            }
        },
        upload: { url in
            let keychain = try DependencyInjection.Container.shared.resolve() as KeychainHandling
            let host = try keychain.get(key: .host)
            let password = try keychain.get(key: .pwd)
            let username = try keychain.get(key: .username)

            let ssh = try SSH(host: host!, port: 22)
            try ssh.authenticate(username: username!, password: password!)
            let sftp = try ssh.openSftp()

            try sftp.upload(localURL: url, remotePath: "backup/backup.xxm")
        },
        fetch: { (authParams, completion) in
            let host = authParams.0
            let username = authParams.1
            let password = authParams.2

            do {
                let ssh = try SSH(host: host, port: 22)
                try ssh.authenticate(username: username, password: password)
                let sftp = try ssh.openSftp()

                let keychain = try DependencyInjection.Container.shared.resolve() as KeychainHandling
                try keychain.store(key: .host, value: host)
                try keychain.store(key: .pwd, value: password)
                try keychain.store(key: .username, value: username)

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
        download: { path in
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
        justAuthenticate: { host, username, password in
            let keychain = try DependencyInjection.Container.shared.resolve() as KeychainHandling
            try keychain.store(key: .host, value: host)
            try keychain.store(key: .pwd, value: password)
            try keychain.store(key: .username, value: username)
        }
    )
}
