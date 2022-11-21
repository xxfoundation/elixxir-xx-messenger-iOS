import UIKit
import AppCore
import Defaults
import LaunchFeature

public class AppDelegate: UIResponder, UIApplicationDelegate {
  public var coverView: UIView?
  public var window: UIWindow?

  @KeyObject(.hideAppList, defaultValue: false) var shouldHideAppInAppList

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let navController = UINavigationController(rootViewController: LaunchController())
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = RootViewController(navController)
    window?.makeKeyAndVisible()
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
}
