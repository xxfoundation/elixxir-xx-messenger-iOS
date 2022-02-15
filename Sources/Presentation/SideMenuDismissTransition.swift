import UIKit

final class SideMenuDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {

    init(menuAnimator: SideMenuAnimating,
         viewAnimator: UIViewAnimating.Type) {
        self.menuAnimator = menuAnimator
        self.viewAnimator = viewAnimator
        super.init()
    }

    let menuAnimator: SideMenuAnimating
    let viewAnimator: UIViewAnimating.Type

    // MARK: UIViewControllerAnimatedTransitioning

    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval { 0.25 }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
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
