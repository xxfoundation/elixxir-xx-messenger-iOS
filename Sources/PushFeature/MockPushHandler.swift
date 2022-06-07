import UIKit

public struct MockPushHandler: PushHandling {
    public init() {}

    public func registerToken(_ token: Data) {
        // TODO
    }

    public func requestAuthorization(
        _ completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        completion(.success(true))
    }

    public func handlePush(
        _ notification: [AnyHashable : Any],
        _ completion: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        completion(.noData)
    }

    public func handlePush(
        _ request: UNNotificationRequest,
        _ completion: @escaping (UNNotificationContent) -> Void
    ) {
        let content = UNMutableNotificationContent()
        content.title = String(describing: Self.self)
        completion(content)
    }

    public func handleAction(
        _ router: PushRouter,
        _ userInfo: [AnyHashable : Any],
        _ completion: @escaping () -> Void
    ) {
        completion()
    }
}
