import UIKit
import AppCore
import Defaults
import XXClient
import Dependencies
import LaunchFeature
import XXMessengerClient

// MARK: - TO REMOVE FROM PRODUCTION:
import Logging
import PulseUI
import AppNavigation
import PulseLogHandler
// MARK: -

public class AppDelegate: UIResponder, UIApplicationDelegate {
  public var window: UIWindow?
  private var coverView: UIView?
  private var backgroundTimer: Timer?
  private var backgroundTask: UIBackgroundTaskIdentifier?

  @Dependency(\.app.log) var log
  @Dependency(\.navigator) var navigator
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.pushNotificationRouter) var pushNotificationRouter

  @KeyObject(.hideAppList, defaultValue: false) var shouldHideAppInAppList
  @KeyObject(.pushNotifications, defaultValue: false) var isPushNotificationsEnabled

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    LoggingSystem.bootstrap(PersistentLogHandler.init)

    UNUserNotificationCenter.current().delegate = self

    let navController = UINavigationController(rootViewController: LaunchController())
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = RootViewController(navController)
    window?.makeKeyAndVisible()

    pushNotificationRouter.set(.live(navigationController: navController))

//    #if DEBUG
    NotificationCenter.default.addObserver(
      forName: UIApplication.userDidTakeScreenshotNotification,
      object: nil,
      queue: OperationQueue.main
    ) { [weak self] _ in
      guard let self else { return }
      let pulseViewController = PulseUI.MainViewController(store: .shared)
      self.navigator.perform(
        PresentModal(
          pulseViewController,
          from: navController.topViewController!
        )
      )
    }
//    #endif

    return true
  }

  public func applicationWillResignActive(_ application: UIApplication) {
    if shouldHideAppInAppList {
      coverView?.removeFromSuperview()
      coverView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
      coverView?.frame = window?.bounds ?? .zero
      window?.addSubview(coverView!)
    }
  }

  public func applicationDidBecomeActive(_ application: UIApplication) {
    application.applicationIconBadgeNumber = 0
    coverView?.removeFromSuperview()
  }

  public func applicationWillEnterForeground(_ application: UIApplication) {
    resumeMessenger(application)
  }

  public func applicationDidEnterBackground(_ application: UIApplication) {
    stopMessenger(application)
  }

  public func application(
    application: UIApplication,
    shouldAllowExtensionPointIdentifier identifier: String
  ) -> Bool {
    if identifier == UIApplication.ExtensionPointIdentifier.keyboard.rawValue {
      return false /// Disable custom keyboards
    }
    return true
  }

  public func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let incomingURL = userActivity.webpageURL,
          let username = getUsernameFromInvitationDeepLink(incomingURL),
          let router = pushNotificationRouter.get() else {
      return false
    }

    router.navigateTo(.search(username: username), {})
    return true
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  public func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    if messenger.isConnected() {
      do {
        try messenger.registerForNotifications(token: deviceToken)
        isPushNotificationsEnabled = true
      } catch {
        isPushNotificationsEnabled = false
        log(.error(error as NSError))
        print(error.localizedDescription)
      }
    }
  }

  public func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    guard let string = userInfo["type"] as? String,
          let type = NotificationReport.ReportType(rawValue: string) else {
      completionHandler()
      return
    }
    var route: PushNotificationRouter.Route?
    switch type {
    case .e2e, .group:
      guard let source = userInfo["source"] as? Data else {
        completionHandler()
        return
      }
      if type == .e2e {
        route = .contactChat(id: source)
      } else {
        route = .groupChat(id: source)
      }
    default:
      break
    }

    if let route, let router = pushNotificationRouter.get() {
      router.navigateTo(route, completionHandler)
    }
  }

  public func application(
    _ application: UIApplication,
    didReceiveRemoteNotification notification: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    if application.applicationState == .background,
       let csv = notification["notificationData"] as? String,
       let reports = try? messenger.getNotificationReports(notificationCSV: csv) {
      reports
        .filter { $0.forMe }
        .filter { $0.type != .silent }
        .filter { $0.type != .default }
        .map {
          let content = UNMutableNotificationContent()
          content.badge = 1
          content.body = ""
          content.sound = .default
          content.userInfo["source"] = $0.source
          content.userInfo["type"] = $0.type.rawValue
          content.threadIdentifier = "new_message_identifier"
          return content
        }.map {
          UNNotificationRequest(
            identifier: Bundle.main.bundleIdentifier!,
            content: $0,
            trigger: UNTimeIntervalNotificationTrigger(
              timeInterval: 1,
              repeats: false
            )
          )
        }.forEach {
          UNUserNotificationCenter.current().add($0) { error in
            error == nil ? completionHandler(.newData) : completionHandler(.failed)
          }
        }
    } else {
      completionHandler(.noData)
    }
  }
}

extension AppDelegate {
  private func resumeMessenger(_ application: UIApplication) {
    backgroundTimer?.invalidate()
    backgroundTimer = nil
    if let backgroundTask {
      application.endBackgroundTask(backgroundTask)
    }
    do {
      if messenger.isLoaded() {
        try messenger.start()
      }
    } catch {
      log(.error(error as NSError))
      print(error.localizedDescription)
    }
  }

  private func stopMessenger(_ application: UIApplication) {
    guard messenger.isLoaded() else { return }

    backgroundTask = application.beginBackgroundTask(withName: "STOPPING_NETWORK")
    backgroundTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
      guard let self else { return }

      if application.backgroundTimeRemaining <= 5 {
        do {
          self.backgroundTimer?.invalidate()
          try self.messenger.stop()
        } catch {
          self.log(.error(error as NSError))
          print(error.localizedDescription)
        }
        if let backgroundTask = self.backgroundTask {
          application.endBackgroundTask(backgroundTask)
        }
      }
    }
  }
}

func getUsernameFromInvitationDeepLink(_ url: URL) -> String? {
  if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
     components.scheme == "https",
     components.host == "elixxir.io",
     components.path == "/connect",
     let queryItem = components.queryItems?.first(where: { $0.name == "username" }),
     let username = queryItem.value {
    return username
  }
  return nil
}
