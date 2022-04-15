import os
import Bindings
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    let logger = Logger(subsystem: "logs_xxmessenger", category: "NotificationService.swift")
    let signpostLogger = OSLog(subsystem: "logs_xxmessenger", category: "NotificationService.swift")

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        logger.debug("didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void)")

        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let data = bestAttemptContent?.userInfo["notificationData"] as? String,
              let defaults = UserDefaults(suiteName: "group.io.xxlabs.notification"),
              let preImage = defaults.value(forKey: "preImage") as? String else {
                  contentHandler(UNNotificationContent())
                  logger.error("Failure: No notification data on the payload or no UserDefaults for group.io.xxlabs.notification or no preImage stored.")
                  return
              }

        var error: NSError?

        os_signpost(.begin, log: signpostLogger, name: "BindingsNotificationsForMe")

        guard let reports = BindingsNotificationsForMe(data, preImage, &error) else {
            logger.error("Failure: report list from BindingsNotificationsForMe is nil")
            os_signpost(.end, log: signpostLogger, name: "BindingsNotificationsForMe")
            return
        }

        os_signpost(.end, log: signpostLogger, name: "BindingsNotificationsForMe")

        let length = reports.len()
        logger.debug("Amount of reports present: \(length, privacy: .public)")

        var showNotification = false

        let content = UNMutableNotificationContent()
        content.sound = .default
        content.badge = 1
        content.threadIdentifier = "new_message_identifier"

        for index in 0..<length {
            do {
                let report = try reports.get(index)
                let isForMe = report.forMe()
                let isNotDefault = report.type() != "default"
                let isNotSilent = report.type() != "silent"

                switch report.type() {
                case "default", "silent":
                    break
                case "request":
                    content.title = "Request received"
                case "confirm":
                    content.title = "Request accepted"
                case "e2e":
                    content.title = "New private message"
                case "group":
                    content.title = "New group message"
                case "endFT":
                    content.title = "New media received"
                case "groupRq":
                    content.title = "Group request received"
                case "reset":
                    content.title = "One of your contacts has restored their account"
                default:
                    break
                }

                logger.log("Type present on the report being iterated: \(report.type(), privacy: .public)")

                if isForMe {
                    logger.debug("This notification is for me")
                } else {
                    logger.debug("This notification is NOT for me")
                }

                if isForMe && isNotSilent && isNotDefault {
                    logger.debug("This notification is for me AND its not silent AND is not default -> Will display")
                    showNotification = true
                    break
                } else {
                    logger.debug("Failure: Its either typed default, silent or its not actually for me")
                }

            } catch {
                logger.error("Failure: reports.get raised an exception: \(error.localizedDescription, privacy: .public)")
            }
        }

        guard showNotification == true else {
            logger.debug("Failure: One or more conditions failed. Aborting notification...")
            return
        }

        if let error = error {
            contentHandler(UNNotificationContent())
            logger.error("Failure: An error was written by NotificationsForMe bindings function: \(error.localizedDescription, privacy: .public)")
            return
        }

        contentHandler(content)

        logger.debug("A push was successfully presented")
    }

    override func serviceExtensionTimeWillExpire() {
        logger.trace("serviceExtensionTimeWillExpire()")
    }
}
