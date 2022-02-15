import UIKit

public final class FullscreenPresenter: NSObject, Presenting {
    private var transition: FullscreenTransition?

    public func present(_ viewController: UIViewController, from parent: UIViewController) {
        viewController.modalPresentationStyle = .overFullScreen
        viewController.transitioningDelegate = self

        parent.present(viewController, animated: true)
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension FullscreenPresenter: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition = FullscreenTransition(onDismissal: { [weak self] in
            self?.transition = nil
        })

        return transition
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition?.direction = .dismiss
        return transition
    }
}
