import Shout
import Socket
import Keychain
import Foundation
import DependencyInjection

public struct SFTPServiceBackupDownloader {
    public var download: (String, @escaping SFTPDownloadResult) -> Void

    public func callAsFunction(path: String, completion: @escaping SFTPDownloadResult) {
        download(path, completion)
    }
}

extension SFTPServiceBackupDownloader {
    static let mock = SFTPServiceBackupDownloader { path, _ in
        print("^^^ Requested backup download on sftp service.")
        print("^^^ Path: \(path)")
    }

    static let live = SFTPServiceBackupDownloader { path, completion in
        DispatchQueue.global().async {
            do {
                let keychain = try DependencyInjection.Container.shared.resolve() as KeychainHandling
                let host = try keychain.get(key: .host)
                let password = try keychain.get(key: .pwd)
                let username = try keychain.get(key: .username)

                let ssh = try SSH(host: host!, port: 22)
                try ssh.authenticate(username: username!, password: password!)
                let sftp = try ssh.openSftp()

                let localURL = FileManager.default
                    .containerURL(forSecurityApplicationGroupIdentifier: "group.elixxir.messenger")!
                    .appendingPathComponent("sftp")

                try sftp.download(remotePath: path, localURL: localURL)

                let data = try Data(contentsOf: localURL)
                completion(.success(data))
            } catch {
                completion(.failure(error))

                if var error = error as? SSHError {
                    print(error.kind)
                    print(error.message)
                    print(error.description)
                } else {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
