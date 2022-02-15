import UIKit

public protocol CenterPresenterNonDismissingTarget: UIViewController {}

public final class CenterPresenter: NSObject, Presenting {
    private var transition: CenterTransition?

    public func present(_ viewController: UIViewController, from parent: UIViewController) {
        viewController.modalPresentationStyle = .overFullScreen
        viewController.transitioningDelegate = self

        parent.present(viewController, animated: true)
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension CenterPresenter: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition = CenterTransition(
            onDismissal: { [weak self] in self?.transition = nil },
            dismissable: (presented is CenterPresenterNonDismissingTarget) == false)

        return transition
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition?.direction = .dismiss
        return transition
    }
}
