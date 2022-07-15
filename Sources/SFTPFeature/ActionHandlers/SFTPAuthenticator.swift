import Shout
import Socket
import Keychain
import Foundation
import DependencyInjection

public struct SFTPAuthenticator {
    public var authenticate: (String, String, String) throws -> Void

    public func callAsFunction(host: String, username: String, password: String) throws {
        try authenticate(host, username, password)
    }
}

extension SFTPAuthenticator {
    static let mock = SFTPAuthenticator { host, username, password in
        print("^^^ Requested authentication on sftp service.")
        print("^^^ Host: \(host)")
        print("^^^ Username: \(username)")
        print("^^^ Password: \(password)")
    }

    static let live = SFTPAuthenticator { host, username, password in
        do {
            try SSH.connect(
                host: host,
                port: 22,
                username: username,
                authMethod: SSHPassword(password)) { ssh in
                    _ = try ssh.openSftp()

                    let keychain = try DependencyInjection.Container.shared.resolve() as KeychainHandling
                    try keychain.store(key: .host, value: host)
                    try keychain.store(key: .pwd, value: password)
                    try keychain.store(key: .username, value: username)
                }
        } catch {
            if let error = error as? SSHError {
                print(error.kind)
                print(error.message)
                print(error.description)
            } else if let error = error as? Socket.Error {
                print(error.errorCode)
                print(error.description)
                print(error.errorReason)
                print(error.localizedDescription)
            } else {
                print(error.localizedDescription)
            }

            throw error
        }
    }
}
