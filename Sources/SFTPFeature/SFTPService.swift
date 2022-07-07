import Models
import Foundation

public typealias SFTPAuthParams = (String, String, String)
public typealias SFTPFetchResult = (Result<RestoreSettings?, Error>) -> Void
public typealias SFTPFetchParams = (SFTPAuthParams, SFTPFetchResult)

public struct SFTPService {
    public var isAuthorized: () -> Bool
    public var fetch: (SFTPFetchParams) -> Void
    public var justAuthenticate: (SFTPAuthParams) -> Void
}

public extension SFTPService {
    static var mock = SFTPService(
        isAuthorized: {
            false
        },
        fetch: { (authParams, completion) in
            print("^^^ RestoreSFTP Host: \(authParams.0)")
            print("^^^ RestoreSFTP Username: \(authParams.1)")
            print("^^^ RestoreSFTP Password: \(authParams.2)")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                completion(.success(.init(
                    backup: .init(id: "ASDF", date: Date.distantPast, size: 100_000_000),
                    cloudService: .sftp
                )))
            }
        },
        justAuthenticate: { host, username, password in
            // TODO: Store these params on the keychain
        })

    static var live = SFTPService(
        isAuthorized: {
            /// If it has host/username/password on keychain
            /// means its authorized, not that is working
            ///
            true
        },
        fetch: { (authParams, completion) in
            // TODO: Store host/username/password on keychain
        },
        justAuthenticate: { host, username, password in
            // TODO: Store host/username/password on keychain
        }
    )
}
