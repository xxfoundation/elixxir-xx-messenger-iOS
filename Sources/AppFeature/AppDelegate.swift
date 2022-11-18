import UIKit
import AppCore
import LaunchFeature

public class AppDelegate: UIResponder, UIApplicationDelegate {
  public var window: UIWindow?

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
}
