import UIKit
import Navigation

/// Open up view controller on provided parent view controller
public struct OpenUp: Action {
  /// - Parameters:
  ///   - viewController: View controller to present
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  ///   - dismissable: Dismissable upon background touch flag
  public init(
    _ viewController: UIViewController,
    from parent: UIViewController,
    animated: Bool = true,
    dismissable: Bool = true
  ) {
    self.viewController = viewController
    self.parent = parent
    self.animated = animated
    self.dismissable = dismissable
  }

  /// View controller to present
  public var viewController: UIViewController

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool

  /// Dismissable upon background touch flag
  public var dismissable: Bool
}

/// Performs `OpenUp` action
public struct OpenUpNavigator: TypedNavigator {
  let transitioningDelegate = BottomPresenter()

  public init() {}

  public func perform(_ action: OpenUp, completion: @escaping () -> Void) {
    transitioningDelegate.isDismissableOnBackgroundTouch = action.dismissable
    action.viewController.transitioningDelegate = transitioningDelegate
    action.viewController.modalPresentationStyle = .overFullScreen

    action.parent.present(
      action.viewController,
      animated: action.animated,
      completion: completion
    )
  }
}

final class BottomPresenter: NSObject, UIViewControllerTransitioningDelegate {
  var isDismissableOnBackgroundTouch: Bool = true
  private var transition: BottomTransition?

  public func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    transition = BottomTransition(isDismissableOnBackgroundTouch) { [weak self] in
      self?.transition = nil
    }

    return transition
  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition?.direction = .dismiss
    return transition
  }
}

import Combine
import SnapKit
final class BottomTransition: NSObject, UIViewControllerAnimatedTransitioning {
  enum Direction {
    case present
    case dismiss
  }

  let isDismissableOnBackground: Bool
  var direction: Direction = .present
  private let onDismissal: (() -> Void)?
  private weak var darkOverlayView: UIControl?
  private weak var topConstraint: Constraint?
  private weak var bottomConstraint: Constraint?
  private var cancellables = Set<AnyCancellable>()

  private var presentedConstraints: [NSLayoutConstraint] = []
  private var dismissedConstraints: [NSLayoutConstraint] = []

  init(
    _ isDismissableOnBackground: Bool = true,
    onDismissal: (() -> Void)?
  ) {
    self.onDismissal = onDismissal
    self.isDismissableOnBackground = isDismissableOnBackground
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
        guard self.isDismissableOnBackground else { return }
        presentingController?.dismiss(animated: true)
      }.store(in: &cancellables)

    context.containerView.addSubview(presentedView)
    presentedView.translatesAutoresizingMaskIntoConstraints = false

    presentedConstraints = [
      presentedView.leftAnchor.constraint(equalTo: context.containerView.leftAnchor),
      presentedView.rightAnchor.constraint(equalTo: context.containerView.rightAnchor),
      presentedView.bottomAnchor.constraint(equalTo: context.containerView.bottomAnchor),
      presentedView.topAnchor.constraint(
        greaterThanOrEqualTo: context.containerView.safeAreaLayoutGuide.topAnchor,
        constant: 60
      )
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
        self?.onDismissal?()
      })
  }
}
