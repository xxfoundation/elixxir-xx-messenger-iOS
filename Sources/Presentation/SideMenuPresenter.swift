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

    public func present(_ viewControllers: UIViewController..., from parent: UIViewController) {
        guard let screen = viewControllers.first else {
            fatalError("Tried to present empty list of view controllers")
        }

        screen.modalPresentationStyle = .overFullScreen
        screen.transitioningDelegate = self
        parent.present(screen, animated: true)
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
