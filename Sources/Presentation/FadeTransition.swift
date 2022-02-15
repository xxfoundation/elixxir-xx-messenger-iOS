import UIKit
import Combine
import SnapKit
import Shared

final class FadeTransition: NSObject, UIViewControllerAnimatedTransitioning {
    enum Direction {
        case present
        case dismiss
    }

    var direction: Direction = .present
    private let didDismiss: EmptyClosure
    private weak var darkOverlayView: UIControl?

    init(didDismiss: @escaping EmptyClosure) {
        self.didDismiss = didDismiss
        super.init()
    }

    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval { 0.25 }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        switch direction {
        case .present:
            present(using: context)
        case .dismiss:
            dismiss(using: context)
        }
    }

    private func present(using context: UIViewControllerContextTransitioning) {
        guard let presentedView = context.view(forKey: .to) else {
            context.completeTransition(false)
            return
        }

        let darkOverlayView = UIControl()
        self.darkOverlayView = darkOverlayView

        darkOverlayView.alpha = 0.0
        darkOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        context.containerView.addSubview(darkOverlayView)
        darkOverlayView.frame = context.containerView.bounds

        context.containerView.addSubview(presentedView)
        presentedView.alpha = 0.0

        presentedView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        presentedView.snp.makeConstraints { $0.edges.equalToSuperview() }

        UIView.animate(
            withDuration: transitionDuration(using: context),
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .curveEaseInOut,
            animations: {
                darkOverlayView.alpha = 1.0
                presentedView.alpha = 1.0
                presentedView.transform = .identity
            },
            completion: { _ in
                context.completeTransition(true)
            })
    }

    private func dismiss(using context: UIViewControllerContextTransitioning) {
        guard let presentedView = context.view(forKey: .from) else {
            context.completeTransition(false)
            return
        }

        UIView.animate(
            withDuration: transitionDuration(using: context),
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .curveEaseInOut,
            animations: { [weak darkOverlayView] in
                darkOverlayView?.alpha = 0.0
                presentedView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                presentedView.alpha = 0.0
            },
            completion: { [weak self] _ in
                context.completeTransition(true)
                self?.didDismiss()
            })
    }
}
