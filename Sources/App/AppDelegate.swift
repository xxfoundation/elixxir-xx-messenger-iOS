import UIKit
import BackgroundTasks

import Theme
import XXLogger
import Defaults
import Integration
import PushFeature
import ToastFeature
import SwiftyDropbox
import LaunchFeature
import DropboxFeature
import CrashReporting
import DependencyInjection

public class AppDelegate: UIResponder, UIApplicationDelegate {
    @Dependency private var pushRouter: PushRouter
    @Dependency private var pushHandler: PushHandling
    @Dependency private var crashReporter: CrashReporter
    @Dependency private var dropboxService: DropboxInterface

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
        #if DEBUG
        DependencyRegistrator.registerForMock()
        #else
        DependencyRegistrator.registerForLive()
        #endif

        if recordingLogs {
            XXLogger.start()
        }

        crashReporter.configure()
        crashReporter.setEnabled(isCrashReportingEnabled)

        UNUserNotificationCenter.current().delegate = self

        let window = Window()
        let navController = UINavigationController(rootViewController: LaunchController())
        window.rootViewController = StatusBarViewController(ToastViewController(navController))
        window.backgroundColor = UIColor.white
        window.makeKeyAndVisible()
        self.window = window

        DependencyInjection.Container.shared.register(
            PushRouter.live(navigationController: navController)
        )

        return true
    }

    public func application(application: UIApplication, shouldAllowExtensionPointIdentifier: String) -> Bool {
        false
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        if let session = try? DependencyInjection.Container.shared.resolve() as SessionType {
            let backgroundTask = application.beginBackgroundTask(withName: "xx.stop.network") {}

            // An option here would be: create async completion closure

            backgroundTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                guard UIApplication.shared.backgroundTimeRemaining > 8 else {
                    if !self.calledStopNetwork {
                        self.calledStopNetwork = true
                        session.stop()
                    } else {
                        if session.hasRunningTasks == false {
                            application.endBackgroundTask(backgroundTask)
                            timer.invalidate()
                        }
                    }

                    return
                }

                guard UIApplication.shared.backgroundTimeRemaining > 9 else {
                    if !self.forceFailedPendingMessages {
                        self.forceFailedPendingMessages = true
                        session.forceFailMessages()
                    }

                    return
                }
            }
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
        if let session = try? DependencyInjection.Container.shared.resolve() as SessionType {
            session.stop()
        }
    }

    public func applicationWillEnterForeground(_ application: UIApplication) {
        if backgroundTimer != nil {
            backgroundTimer?.invalidate()
            backgroundTimer = nil
        }

        if let session = try? DependencyInjection.Container.shared.resolve() as SessionType {
            guard self.calledStopNetwork == true else { return }
            session.start()
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
        dropboxService.handleOpenUrl(url)
    }
}

// MARK: Notifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        pushHandler.handleAction(pushRouter, userInfo, completionHandler)
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
