import UIKit

public final class BottomPresenter: NSObject, Presenting {
    private var transition: BottomTransition?
    
    public func present(_ viewControllers: UIViewController..., from parent: UIViewController) {
        guard let screen = viewControllers.first else {
            fatalError("Tried to present empty list of view controllers")
        }

        screen.modalPresentationStyle = .overFullScreen
        screen.transitioningDelegate = self
        parent.present(screen, animated: true)
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension BottomPresenter: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition = BottomTransition(onDismissal: { [weak self] in
            self?.transition = nil
        })
        
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition?.direction = .dismiss
        return transition
    }
}
