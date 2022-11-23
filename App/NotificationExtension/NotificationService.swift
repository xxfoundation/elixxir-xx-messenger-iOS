import XXModels
import XXClient
import XXDatabase
import ReportingFeature
import XXMessengerClient
import UserNotifications

final class NotificationService: UNNotificationServiceExtension {
  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    guard let defaults = UserDefaults(suiteName: "group.elixxir.messenger") else { return }

    var environment = MessengerEnvironment.live()
    environment.serviceList = .userDefaults(key: "preImage", userDefaults: defaults)
    let messenger = Messenger.live(environment)
    let userInfo = request.content.userInfo
    let dbPath = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: "group.elixxir.messenger")!
      .appendingPathComponent("xxm_databasse")
      .appendingPathExtension("sqlite").path

    guard let csv = userInfo["notificationData"] as? String,
          let reports = try? messenger.getNotificationReports(notificationCSV: csv) else { return }
    reports
      .filter { $0.forMe }
      .filter { $0.type != .silent }
      .filter { $0.type != .default }
      .compactMap {
        let content = UNMutableNotificationContent()
        content.badge = 1
        content.sound = .default
        content.threadIdentifier = "new_message_identifier"
        content.userInfo["type"] = $0.type.rawValue
        content.userInfo["source"] = $0.source
        content.body = getBodyForUnknownWith(type: $0.type)

        guard let db = try? Database.onDisk(path: dbPath),
              let contact = try? db.fetchContacts(.init(id: [$0.source])).first else {
          return content
        }
        if ReportingStatus.live().isEnabled(), (contact.isBlocked || contact.isBanned) {
          return nil
        }
        if let showSender = defaults.value(forKey: "isShowingUsernames") as? Bool, showSender == true {
          let name = (contact.nickname ?? contact.username) ?? ""
          content.body = getBodyFor(name: name, with: $0.type)
        }
        return content
      }.forEach {
        contentHandler($0)
      }
  }

  private func getBodyForUnknownWith(type: NotificationReport.ReportType) -> String {
    switch type {
    case .`default`, .silent:
      fatalError()
    case .request:
      return "Request received"
    case .reset:
      return "One of your contacts has restored their account"
    case .confirm:
      return "Request accepted"
    case .e2e:
      return "New private message"
    case .group:
      return "New group message"
    case .endFT:
      return "New media received"
    case .groupRQ:
      return "Group request received"
    }
  }

  private func getBodyFor(name: String, with type: NotificationReport.ReportType) -> String {
    switch type {
    case .silent, .`default`:
      fatalError()
    case .e2e:
      return String(format: "%@ sent you a private message", name)
    case .reset:
      return String(format: "%@ restored their account", name)
    case .endFT:
      return String(format: "%@ sent you a file", name)
    case .group:
      return String(format: "%@ sent you a group message", name)
    case .groupRQ:
      return String(format: "%@ sent you a group request", name)
    case .confirm:
      return String(format: "%@ confirmed your contact request", name)
    case .request:
      return String(format: "%@ sent you a contact request", name)
    }
  }
}
