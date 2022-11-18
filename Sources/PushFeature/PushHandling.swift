import UIKit

public protocol PushHandling {
  /// Submits the APNS token to a 3rd-party service.
  /// This should be called whenever the user accepts
  /// receiving remote push notifications.
  ///
  /// - Parameters:
  ///   - token: The APNS provided token
  ///
  func registerToken(
    _ token: Data
  )

  /// Prompts a system alert to the user requesting
  /// permission for receiving remote push notifications
  ///
  /// - Parameters:
  ///   - completion: Async result closure containing the user reponse
  ///
  func requestAuthorization(
    _ completion: @escaping (Result<Bool, Error>) -> Void
  )

  /// Evaluates if the notification should be displayed or not
  /// and if yes, how should it look like.
  ///
  /// - Note: This function should be called by the main app target
  /// - Warning: The notifications should only appear if the app is in background
  ///
  /// - Parameters:
  ///   - userInfo: Dictionary contaning the payload of the remote push
  ///   - completion: Async closure containing the operation chosed
  ///
  func handlePush(
    _ userInfo: [AnyHashable: Any],
    _ completion: @escaping (UIBackgroundFetchResult) -> Void
  )

  /// Evaluates if the notification should be displayed or not
  ///  and if yes, how it should look like and who is it from
  ///
  /// - Note: This function should be called by the `NotificationExtension`
  ///
  /// - Parameters:
  ///   - request: The notification request that arrived for the `NotificationExtension`
  ///   - completion: Async closure containing the operation chosed
  ///
  func handlePush(
    _ request: UNNotificationRequest,
    _ completion: @escaping (UNNotificationContent) -> Void
  )

  /// Deeplinks to any UI flow set within the notification.
  /// It can get called either when the user starts the app
  /// from a notification or when the user has the app in
  /// background and resumes the app by tapping on a push
  ///
  /// - Parameters:
  ///   - router: Router instance that will decide the correct UI flow
  ///   - userInfo: Dictionary contaning the payload of the notification
  ///   - completion: Async empty closure
  ///
  func handleAction(
    _ router: PushRouter,
    _ userInfo: [AnyHashable: Any],
    _ completion: @escaping () -> Void
  )
}
