import Shout
import Socket
import Models
import Keychain
import Foundation
import DependencyInjection

public typealias SFTPUploadResult = (Result<Backup, Error>) -> Void

public struct SFTPUploader {
    public var upload: (URL, @escaping SFTPUploadResult) -> Void

    public func callAsFunction(url: URL, completion: @escaping SFTPUploadResult) {
        upload(url, completion)
    }
}

extension SFTPUploader {
    static let mock = SFTPUploader(
        upload: { url, _ in
            print("^^^ Requested upload on sftp service")
            print("^^^ URL path: \(url.path)")
        }
    )

    static let live = SFTPUploader { url, completion in
        DispatchQueue.global().async {
            do {
                let keychain = try DependencyInjection.Container.shared.resolve() as KeychainHandling
                let host = try keychain.get(key: .host)
                let password = try keychain.get(key: .pwd)
                let username = try keychain.get(key: .username)

                let ssh = try SSH(host: host!, port: 22)
                try ssh.authenticate(username: username!, password: password!)
                let sftp = try ssh.openSftp()

                let data = try Data(contentsOf: url)

                if (try? sftp.listFiles(in: "backup")) == nil {
                    try sftp.createDirectory("backup")
                }

                try sftp.upload(data: data, remotePath: "backup/backup.xxm")

                completion(.success(.init(
                    id: "backup/backup.xxm",
                    date: Date(),
                    size: Float(data.count)
                )))
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
