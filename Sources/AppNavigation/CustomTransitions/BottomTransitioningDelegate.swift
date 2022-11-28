import UIKit

final class BottomTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
  var isDismissableOnBackgroundTouch: Bool = true
  private var transition: BottomTransition?

  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    transition = BottomTransition(isDismissableOnBackgroundTouch) { [weak self] in
      guard let self else { return }
      self.transition = nil
    }
    return transition
  }

  func animationController(
    forDismissed dismissed: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    transition?.direction = .dismiss
    return transition
  }
}
