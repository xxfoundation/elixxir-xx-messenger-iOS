import UIKit
import Navigation
import BackgroundTasks

import Shared
import XXModels
import XXLogger
import Defaults
import PushFeature
import LaunchFeature
import CrashReporting
import DependencyInjection

import XXClient
import XXMessengerClient

import CloudFiles
import CloudFilesDrive
import CloudFilesICloud
import CloudFilesDropbox

public class AppDelegate: UIResponder, UIApplicationDelegate {
  @Dependency var navigator: Navigator
  @Dependency var pushHandler: PushHandling
  @Dependency var crashReporter: CrashReporter

  @KeyObject(.hideAppList, defaultValue: false) var hideAppList: Bool
  @KeyObject(.recordingLogs, defaultValue: true) var recordingLogs: Bool
  @KeyObject(.crashReporting, defaultValue: true) var isCrashReportingEnabled: Bool

  var calledStopNetwork = false
  var forceFailedPendingMessages = false

  var coverView: UIView?
  var backgroundTimer: Timer?
  public var window: UIWindow?

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    DependencyRegistrator.registerDependencies()
    setupCloudFilesManagers()
    setupCrashReporting()
    setupLogging()

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = RootViewController(UINavigationController(rootViewController: LaunchController()))
    window?.makeKeyAndVisible()
    return true
  }

  public func application(application: UIApplication, shouldAllowExtensionPointIdentifier: String) -> Bool {
    false
  }

  public func applicationDidEnterBackground(_ application: UIApplication) {
    if let messenger = try? DependencyInjection.Container.shared.resolve() as Messenger,
       let database = try? DependencyInjection.Container.shared.resolve() as Database,
       let cMix = try? messenger.cMix.tryGet() {
      let backgroundTask = application.beginBackgroundTask(withName: "xx.stop.network") {}

      backgroundTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
        print(">>> .backgroundTimeRemaining: \(UIApplication.shared.backgroundTimeRemaining)")

        guard UIApplication.shared.backgroundTimeRemaining > 8 else {
          if !self.calledStopNetwork {
            self.calledStopNetwork = true
            try! messenger.stop()
            print(">>> Called stopNetworkFollower")
          } else {
            if cMix.hasRunningProcesses() == false {
              application.endBackgroundTask(backgroundTask)
              timer.invalidate()
            }
          }

          return
        }

        guard UIApplication.shared.backgroundTimeRemaining > 9 else {
          if !self.forceFailedPendingMessages {
            self.forceFailedPendingMessages = true

            let query = Message.Query(status: [.sending])
            let assignment = Message.Assignments(status: .sendingFailed)
            _ = try? database.bulkUpdateMessages(query, assignment)
          }

          return
        }
      })
    }
  }

  public func applicationWillResignActive(_ application: UIApplication) {
    if hideAppList {
      coverView?.removeFromSuperview()
      coverView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
      coverView?.frame = window?.bounds ?? .zero
      window?.addSubview(coverView!)
    }
  }

  public func applicationWillTerminate(_ application: UIApplication) {
    if let messenger = try? DependencyInjection.Container.shared.resolve() as Messenger {
      try? messenger.stop()
    }
  }

  public func applicationWillEnterForeground(_ application: UIApplication) {
    if backgroundTimer != nil {
      backgroundTimer?.invalidate()
      backgroundTimer = nil
      print(">>> Invalidated background timer")
    }

    if let messenger = try? DependencyInjection.Container.shared.resolve() as Messenger,
       let cMix = messenger.cMix.get() {
      guard self.calledStopNetwork == true else { return }
      try? cMix.startNetworkFollower(timeoutMS: 10_000)
      print(">>> Called startNetworkFollower")
      self.calledStopNetwork = false
    }
  }

  public func applicationDidBecomeActive(_ application: UIApplication) {
    application.applicationIconBadgeNumber = 0
    coverView?.removeFromSuperview()
  }

  public func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    handleRedirectURL(url)
  }

  public func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let incomingURL = userActivity.webpageURL,
          let username = getUsernameFromInvitationDeepLink(incomingURL),
          let router = try? DependencyInjection.Container.shared.resolve() as PushRouter else {
      return false
    }

    router.navigateTo(.search(username: username), {})
    return true
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  public func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    //pushHandler.handleAction(pushRouter, userInfo, completionHandler)
  }

  public func application(
    _ application: UIApplication,
    didReceiveRemoteNotification notification: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    pushHandler.handlePush(notification, completionHandler)
  }

  public func application(
    _: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    pushHandler.registerToken(deviceToken)
  }
}

extension AppDelegate {
  private func setupCrashReporting() {
    crashReporter.configure()
    crashReporter.setEnabled(isCrashReportingEnabled)
  }

  private func setupCloudFilesManagers() {
    CloudFilesManager.all[.icloud] = .iCloud(fileName: "backup.xxm")
    CloudFilesManager.all[.dropbox] = .dropbox(appKey: "ppx0de5f16p9aq2", path: "/backup/backup.xxm")
    CloudFilesManager.all[.drive] = .drive(
      apiKey: "AIzaSyCbI2yQ7pbuVSRvraqanjGcS9CDrjD7lNU",
      clientId: "662236151640-herpu89qikpfs9m4kvbi9bs5fpdji5de.apps.googleusercontent.com",
      fileName: "backup.xxm"
    )
  }

  private func setupLogging() {
    if recordingLogs {
      XXLogger.start()
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
