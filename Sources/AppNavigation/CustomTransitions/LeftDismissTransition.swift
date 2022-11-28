import UIKit

final class LeftDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
  let menuAnimator: LeftAnimating
  let viewAnimator: UIViewAnimating.Type

  init(
    menuAnimator: LeftAnimating,
    viewAnimator: UIViewAnimating.Type
  ) {
    self.menuAnimator = menuAnimator
    self.viewAnimator = viewAnimator
    super.init()
  }

  func transitionDuration(
    using context: UIViewControllerContextTransitioning?
  ) -> TimeInterval { 0.25 }

  func animateTransition(
    using context: UIViewControllerContextTransitioning
  ) {
    viewAnimator.animate(
      withDuration: transitionDuration(using: context),
      animations: {
        self.menuAnimator.animate(in: context.containerView, to: 0)
      },
      completion: { _ in
        let isCancelled = context.transitionWasCancelled
        context.completeTransition(isCancelled == false)
      }
    )
  }
}
