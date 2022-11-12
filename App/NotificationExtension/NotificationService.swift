import PushFeature
import UserNotifications

final class NotificationService: UNNotificationServiceExtension {
  private let pushHandler = PushHandler()

  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    pushHandler.handlePush(request, contentHandler)
  }
}
