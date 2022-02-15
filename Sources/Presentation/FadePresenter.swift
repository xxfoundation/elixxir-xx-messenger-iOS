import UIKit

public final class FadePresenter: NSObject, Presenting {
    private var transition: FadeTransition?

    public func present(_ target: UIViewController, from parent: UIViewController) {
        target.modalPresentationStyle = .overFullScreen
        target.transitioningDelegate = self

        parent.present(target, animated: true)
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
