import UIKit
import Shared

public protocol UIViewAnimating {
  static func animate(
    withDuration duration: TimeInterval,
    animations: @escaping EmptyClosure,
    completion: ((Bool) -> Void)?
  )
}

extension UIView: UIViewAnimating {}
