import UIKit
import Theme
import Shared

final class UpdateBlocker {
    private(set) var window: Window? = Window()

    func showWindow() {
        window?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        window?.rootViewController = StatusBarViewController(nil)
        window?.alpha = 0.0
        window?.makeKeyAndVisible()

        UIView.animate(withDuration: 0.3) { self.window?.alpha = 1.0 }
    }

    func hideWindow() {
        UIView.animate(withDuration: 0.3) {
            self.window?.alpha = 0.0
        } completion: { _ in
            self.window = nil
        }
    }
}
