import UIKit
import Combine
import SnapKit
import Shared

final class BottomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    enum Direction {
        case present
        case dismiss
    }

    var direction: Direction = .present
    private let onDismissal: EmptyClosure
    private weak var darkOverlayView: UIControl?
    private weak var topConstraint: Constraint?
    private weak var bottomConstraint: Constraint?
    private var cancellables = Set<AnyCancellable>()

    private var presentedConstraints: [NSLayoutConstraint] = []
    private var dismissedConstraints: [NSLayoutConstraint] = []

    init(onDismissal: @escaping EmptyClosure) {
        self.onDismissal = onDismissal
        super.init()
    }

    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval { 0.5 }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        switch direction {
        case .present:
            present(using: context)
        case .dismiss:
            dismiss(using: context)
        }
    }

    private func present(using context: UIViewControllerContextTransitioning) {
        guard let presentingController = context.viewController(forKey: .from),
              let presentedView = context.view(forKey: .to) else {
            context.completeTransition(false)
            return
        }

        let darkOverlayView = UIControl()
        self.darkOverlayView = darkOverlayView

        darkOverlayView.alpha = 0.0
        darkOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        context.containerView.addSubview(darkOverlayView)
        darkOverlayView.frame = context.containerView.bounds

        darkOverlayView
            .publisher(for: .touchUpInside)
            .sink { [weak presentingController] _ in
                presentingController?.dismiss(animated: true)
            }.store(in: &cancellables)

        context.containerView.addSubview(presentedView)
        presentedView.translatesAutoresizingMaskIntoConstraints = false

        presentedConstraints = [
            presentedView.leftAnchor.constraint(equalTo: context.containerView.leftAnchor),
            presentedView.rightAnchor.constraint(equalTo: context.containerView.rightAnchor),
            presentedView.bottomAnchor.constraint(equalTo: context.containerView.bottomAnchor)
        ]

        dismissedConstraints = [
            presentedView.leftAnchor.constraint(equalTo: context.containerView.leftAnchor),
            presentedView.rightAnchor.constraint(equalTo: context.containerView.rightAnchor),
            presentedView.topAnchor.constraint(equalTo: context.containerView.bottomAnchor)
        ]

        NSLayoutConstraint.activate(dismissedConstraints)

        context.containerView.setNeedsLayout()
        context.containerView.layoutIfNeeded()

        NSLayoutConstraint.deactivate(dismissedConstraints)
        NSLayoutConstraint.activate(presentedConstraints)

        UIView.animate(
            withDuration: transitionDuration(using: context),
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .curveEaseInOut,
            animations: {
                darkOverlayView.alpha = 1.0
                context.containerView.setNeedsLayout()
                context.containerView.layoutIfNeeded()
            },
            completion: { _ in
                context.completeTransition(true)
            })
    }

    private func dismiss(using context: UIViewControllerContextTransitioning) {
        NSLayoutConstraint.deactivate(presentedConstraints)
        NSLayoutConstraint.activate(dismissedConstraints)

        UIView.animate(
            withDuration: transitionDuration(using: context),
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .curveEaseInOut,
            animations: { [weak darkOverlayView] in
                darkOverlayView?.alpha = 0.0
                context.containerView.setNeedsLayout()
                context.containerView.layoutIfNeeded()
            },
            completion: { [weak self] _ in
                context.completeTransition(true)
                self?.onDismissal()
            })
    }
}
