import UIKit

public final class SideMenuPresenter: NSObject,
                                      Presenting,
                                      UIViewControllerTransitioningDelegate {

    public init(dismissInteractor: SideMenuDismissInteracting = SideMenuDismissInteractor(),
                menuAnimator: SideMenuAnimating = SideMenuAnimator(),
                viewAnimator: UIViewAnimating.Type = UIView.self) {
        self.dismissInteractor = dismissInteractor
        self.menuAnimator = menuAnimator
        self.viewAnimator = viewAnimator
        super.init()
    }

    let dismissInteractor: SideMenuDismissInteracting
    let menuAnimator: SideMenuAnimating
    let viewAnimator: UIViewAnimating.Type
    
    // MARK: Presenting

    public func present(_ target: UIViewController,
                        from parent: UIViewController) {
        target.modalPresentationStyle = .overFullScreen
        target.transitioningDelegate = self
        parent.present(target, animated: true)
    }

    // MARK: UIViewControllerTransitioningDelegate

    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        SideMenuPresentTransition(dismissInteractor: dismissInteractor,
                                  menuAnimator: menuAnimator,
                                  viewAnimator: viewAnimator)
    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        SideMenuDismissTransition(menuAnimator: menuAnimator,
                                  viewAnimator: viewAnimator)
    }

    public func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        dismissInteractor.interactionInProgress ? dismissInteractor : nil
    }
}
