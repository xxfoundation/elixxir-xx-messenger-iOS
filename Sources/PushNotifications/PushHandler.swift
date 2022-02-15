import UIKit
import XXLogger
import Defaults
import os.log
import Integration
import UserNotifications
import DependencyInjection

public protocol PushHandling {
    func didRegisterWith(_ deviceToken: Data)

    func didRequestAuthorization(_ completion: @escaping (Result<Bool, Error>) -> Void)

    func didReceiveRemote(_ notification: [AnyHashable : Any],
                          _ completion: @escaping (UIBackgroundFetchResult) -> Void)
}

public final class PushHandler: PushHandling {
    @Dependency private var logger: XXLogger

    @KeyObject(.pushNotifications, defaultValue: false) private var pushNotifications: Bool

    public init() {}

    public func didReceiveRemote(
        _ notification: [AnyHashable : Any],
        _ completion: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let data = notification["notificationData"] as? String,
              let defaults = UserDefaults(suiteName: "group.io.xxlabs.notification"),
              let preImage = defaults.value(forKey: "preImage") as? String else {
                  completion(.newData)
                  return
              }

        var error: NSError?

        guard let reports = evaluateNotification(data, preImage, &error) else { return }
        let length = reports.len()

        var showNotification = false

        for index in 0..<length {
            if let report = try? reports.get(index: index) {
                let isForMe = report.forMe()
                let isNotDefault = report.type() != "default"
                let isNotSilent = report.type() != "silent"

                if isForMe && isNotSilent && isNotDefault {
                    showNotification = true
                    break
                }
            }
        }

        guard showNotification == true else { return }

        guard error == nil else {
            logger.error(error as Any)
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "New Messages Available"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "io.xxlabs.messenger", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { [weak self] in self?.logger.error($0 as Any) }
    }

    public func didRequestAuthorization(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(granted))
        }
    }

    public func didRegisterWith(_ deviceToken: Data) {
        do {
            logger.info("PushHandling: didRegisterWith(_ deviceToken: Data)")
            let session = try DependencyInjection.Container.shared.resolve() as SessionType
            try session.registerNotifications(deviceToken.hexEncodedString)
            logger.info("PushHandling: didRegisterWith(_ deviceToken: Data) success")
        } catch {
            pushNotifications = false
            logger.error(error)
        }
    }
}

private extension Data {
    var hexEncodedString: String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
