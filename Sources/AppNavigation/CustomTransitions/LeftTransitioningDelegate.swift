import UIKit

protocol UIViewAnimating {
  static func animate(
    withDuration duration: TimeInterval,
    animations: @escaping (() -> Void),
    completion: ((Bool) -> Void)?
  )
}

extension UIView: UIViewAnimating {}

final class LeftTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
  let menuAnimator: LeftAnimating
  let viewAnimator: UIViewAnimating.Type
  let dismissInteractor: LeftDismissInteracting

  init(
    dismissInteractor: LeftDismissInteracting = LeftDismissInteractor(),
    menuAnimator: LeftAnimating = LeftAnimator(),
    viewAnimator: UIViewAnimating.Type = UIView.self
  ) {
    self.dismissInteractor = dismissInteractor
    self.menuAnimator = menuAnimator
    self.viewAnimator = viewAnimator
    super.init()
  }

  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    LeftPresentTransition(
      dismissInteractor: dismissInteractor,
      menuAnimator: menuAnimator,
      viewAnimator: viewAnimator
    )
  }

  func animationController(
    forDismissed dismissed: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    LeftDismissTransition(
      menuAnimator: menuAnimator,
      viewAnimator: viewAnimator
    )
  }

  func interactionControllerForDismissal(
    using animator: UIViewControllerAnimatedTransitioning
  ) -> UIViewControllerInteractiveTransitioning? {
    dismissInteractor.interactionInProgress ? dismissInteractor : nil
  }
}
