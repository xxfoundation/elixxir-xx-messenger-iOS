import UIKit
import OSLog
import BackgroundTasks

import Theme
import XXLogger
import Defaults
import Integration
import CrashReporting
import PushNotifications
import DependencyInjection

import OnboardingFeature

let logger = Logger(subsystem: "logs_xxmessenger", category: "AppDelegate.swift")

public class AppDelegate: UIResponder, UIApplicationDelegate {
    @Dependency private var pushHandler: PushHandling
    @Dependency private var crashReporter: CrashReporter

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

        let rootScreen = StatusBarViewController(
            UINavigationController(rootViewController: OnboardingLaunchController())
        )

        window = Window()
        window?.rootViewController = rootScreen
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()

        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        return true
    }

    public func application(application: UIApplication, shouldAllowExtensionPointIdentifier: String) -> Bool {
        false
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        if let session = try? DependencyInjection.Container.shared.resolve() as SessionType {
            let backgroundTask = application.beginBackgroundTask(withName: "xx.stop.network") {
                logger.log("Background task will expire")
            }

            // An option here would be: create async completion closure

            backgroundTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                logger.log("Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)")

                guard UIApplication.shared.backgroundTimeRemaining > 8 else {
                    if !self.calledStopNetwork {
                        self.calledStopNetwork = true
                        session.stop()
                        logger.log("Stopping client threads...")
                    } else {
                        if session.hasRunningTasks == false {
                            application.endBackgroundTask(backgroundTask)
                            timer.invalidate()
                            logger.log("Finished background processes")
                        }
                    }

                    return
                }

                guard UIApplication.shared.backgroundTimeRemaining > 9 else {
                    if !self.forceFailedPendingMessages {
                        self.forceFailedPendingMessages = true
                        logger.log("Background time is running out. Will force-fail all pending messages")
                        session.forceFailMessages()
                    } else {
                        logger.log("Background time is running out without pending messages")
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
            logger.log("applicationWillTerminate but has an ongoing session. Calling stopNetwork...")
            session.stop()
        } else {
            logger.log("applicationWillTerminate without any session")
        }
    }

    public func applicationWillEnterForeground(_ application: UIApplication) {
        if backgroundTimer != nil {
            logger.log("Invalidating background timer...")
            backgroundTimer?.invalidate()
            backgroundTimer = nil
        }

        if let session = try? DependencyInjection.Container.shared.resolve() as SessionType {
            guard self.calledStopNetwork == true else {
                logger.log("A client instance is already running. Moving on...")
                return
            }

            logger.log("A client instance is stopped. Starting network...")
            session.start()
            self.calledStopNetwork = false
        }
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        coverView?.removeFromSuperview()
    }
}

// MARK: Notifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    public func application(
        _: UIApplication,
        didReceiveRemoteNotification notification: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        pushHandler.didReceiveRemote(notification, completionHandler)
    }

    public func application(
        _: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        pushHandler.didRegisterWith(deviceToken)
    }
}
