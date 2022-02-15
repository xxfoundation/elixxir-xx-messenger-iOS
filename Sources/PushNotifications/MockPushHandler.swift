import UIKit

public struct MockPushHandler: PushHandling {
    public init() {}

    public func didRegisterWith(_ deviceToken: Data) {}

    public func didRequestAuthorization(
        _ completion: @escaping (Result<Bool, Error>) -> Void
    ) {}

    public func didReceiveRemote(
        _ notification: [AnyHashable : Any],
        _ completion: @escaping (UIBackgroundFetchResult) -> Void
    ) {}
}
