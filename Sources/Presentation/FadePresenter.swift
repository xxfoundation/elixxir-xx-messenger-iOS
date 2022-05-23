import UIKit

public final class FadePresenter: NSObject, Presenting {
    private var transition: FadeTransition?

    public func present(_ viewControllers: UIViewController..., from parent: UIViewController) {
        guard let screen = viewControllers.first else {
            fatalError("Tried to present empty list of view controllers")
        }

        screen.modalPresentationStyle = .overFullScreen
        screen.transitioningDelegate = self
        parent.present(screen, animated: true)
    }
}

extension FadePresenter: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition = FadeTransition(didDismiss: { [weak self] in self?.transition = nil })
        return transition
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition?.direction = .dismiss
        return transition
    }
}
