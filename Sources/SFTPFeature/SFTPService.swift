import UIKit
import Keychain
import Presentation
import DependencyInjection

public typealias SFTPAuthorizationParams = (UIViewController, () -> Void)

public struct SFTPService {
    public var isAuthorized: () -> Bool
    public var fetchMetadata: SFTPFetcher
    public var uploadBackup: SFTPUploader
    public var authorizeFlow: (SFTPAuthorizationParams) -> Void
    public var authenticate: SFTPAuthenticator
    public var downloadBackup: SFTPDownloader
}

public extension SFTPService {
    static var mock = SFTPService(
        isAuthorized: { true },
        fetchMetadata: .mock,
        uploadBackup: .mock,
        authorizeFlow: { (_, completion) in completion() },
        authenticate: .mock,
        downloadBackup: .mock
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
        fetchMetadata: .live,
        uploadBackup: .live ,
        authorizeFlow: { controller, completion in
            var pushPresenter: Presenting = PushPresenter()
            pushPresenter.present(SFTPController(completion), from: controller)
        },
        authenticate: .live,
        downloadBackup: .live
    )
}
