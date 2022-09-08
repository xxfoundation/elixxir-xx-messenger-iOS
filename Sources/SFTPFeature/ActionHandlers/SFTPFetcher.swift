import Shout
import Socket
import Models
import Keychain
import Foundation
import DependencyInjection

public typealias SFTPFetchResult = (Result<RestoreSettings?, Error>) -> Void

public struct SFTPFetcher {
    public var fetch: (@escaping SFTPFetchResult) -> Void

    public func callAsFunction(completion: @escaping SFTPFetchResult) {
        fetch(completion)
    }
}

extension SFTPFetcher {
    static let mock = SFTPFetcher { _ in
        print("^^^ Requested backup metadata on sftp service.")
    }

    static let live = SFTPFetcher { completion in
        DispatchQueue.global().async {
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
                if let error = error as? SSHError {
                    print(error.kind)
                    print(error.message)
                    print(error.description)
                } else if let error = error as? Socket.Error {
                    print(error.errorCode)
                    print(error.description)
                    print(error.errorReason ?? "No error reason available")
                    print(error.localizedDescription)
                } else {
                    print(error.localizedDescription)
                }

                completion(.failure(error))
            }
        }
    }
}
