import UIKit
import Navigation

/// Open left view controller on provided parent view controller
public struct OpenLeft: Action {
  /// - Parameters:
  ///   - viewController: View controller to present
  ///   - parent: Parent view controller from which presentation should happen
  ///   - animated: Animate the transition
  public init(
    _ viewController: UIViewController,
    from parent: UIViewController,
    animated: Bool = true
  ) {
    self.viewController = viewController
    self.parent = parent
    self.animated = animated
  }

  /// View controller to present
  public var viewController: UIViewController

  /// Parent view controller from which presentation should happen
  public var parent: UIViewController

  /// Animate the transition
  public var animated: Bool
}

/// Performs `OpenLeft` action
public struct OpenLeftNavigator: TypedNavigator {
  let transitioningDelegate = SidePresenter()

  public init() {}

  public func perform(_ action: OpenLeft, completion: @escaping () -> Void) {
    action.viewController.transitioningDelegate = transitioningDelegate
    action.viewController.modalPresentationStyle = .overFullScreen

    action.parent.present(
      action.viewController,
      animated: action.animated,
      completion: completion
    )
  }
}

final class SidePresenter: NSObject, UIViewControllerTransitioningDelegate {
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

public protocol SideMenuAnimating {
  func animate(in containerView: UIView, to progress: CGFloat)
}

public struct SideMenuAnimator: SideMenuAnimating {
  public init() {}

  public func animate(in containerView: UIView, to progress: CGFloat) {
    guard let fromView = containerView.viewWithTag(SideMenuPresentTransition.fromViewTag)
    else { return }

    let cornerRadius = progress * 24
    let shadowOpacity = Float(progress)
    let offsetX = containerView.bounds.size.width * 0.5 * progress
    let offsetY = containerView.bounds.size.height * 0.08 * progress
    let scale = 1 - (0.25 * progress)

    fromView.subviews.first?.layer.cornerRadius = cornerRadius
    fromView.layer.shadowOpacity = shadowOpacity
    fromView.transform = CGAffineTransform.identity
      .translatedBy(x: offsetX, y: offsetY)
      .scaledBy(x: scale, y: scale)
  }
}

import UIKit
import Shared

public protocol SideMenuDismissInteracting: UIViewControllerInteractiveTransitioning {
  var interactionInProgress: Bool { get }

  func setup(view: UIView, action: @escaping EmptyClosure)
}

public final class SideMenuDismissInteractor: UIPercentDrivenInteractiveTransition, SideMenuDismissInteracting {
  private var action: EmptyClosure?
  private var shouldFinishTransition = false

  // MARK: SideMenuDismissInteracting

  public var interactionInProgress = false

  public func setup(view: UIView, action: @escaping EmptyClosure) {
    let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    view.addGestureRecognizer(panRecognizer)

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    view.addGestureRecognizer(tapRecognizer)

    self.action = action
  }

  // MARK: Gesture handling

  @objc
  private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
    action?()
  }

  @objc
  private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
    guard let view = recognizer.view,
          let containerView = view.superview
    else { return }

    let viewWidth = containerView.bounds.size.width
    guard viewWidth > 0 else { return }

    let translation = recognizer.translation(in: view)
    let progress = min(1, max(0, -translation.x / (viewWidth * 0.8)))

    switch recognizer.state {
    case .possible, .failed:
      interactionInProgress = false

    case .began:
      interactionInProgress = true
      shouldFinishTransition = false
      action?()

    case .changed:
      shouldFinishTransition = progress >= 0.5
      update(progress)

    case .cancelled:
      interactionInProgress = false
      cancel()

    case .ended:
      interactionInProgress = false
      shouldFinishTransition ? finish() : cancel()

    @unknown default:
      interactionInProgress = false
      cancel()
    }
  }
}

import UIKit

final class SideMenuDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {

  init(menuAnimator: SideMenuAnimating,
       viewAnimator: UIViewAnimating.Type) {
    self.menuAnimator = menuAnimator
    self.viewAnimator = viewAnimator
    super.init()
  }

  let menuAnimator: SideMenuAnimating
  let viewAnimator: UIViewAnimating.Type

  // MARK: UIViewControllerAnimatedTransitioning

  func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval { 0.25 }

  func animateTransition(using context: UIViewControllerContextTransitioning) {
    viewAnimator.animate(
      withDuration: transitionDuration(using: context),
      animations: {
        self.menuAnimator.animate(in: context.containerView, to: 0)
      },
      completion: { _ in
        let isCancelled = context.transitionWasCancelled
        context.completeTransition(isCancelled == false)
      }
    )
  }
}

import UIKit
import Shared

final class SideMenuPresentTransition: NSObject, UIViewControllerAnimatedTransitioning {
  static let fromViewTag = UUID().hashValue

  init(
    dismissInteractor: SideMenuDismissInteracting,
    menuAnimator: SideMenuAnimating,
    viewAnimator: UIViewAnimating.Type
  ) {
    self.dismissInteractor = dismissInteractor
    self.menuAnimator = menuAnimator
    self.viewAnimator = viewAnimator
    super.init()
  }

  let dismissInteractor: SideMenuDismissInteracting
  let menuAnimator: SideMenuAnimating
  let viewAnimator: UIViewAnimating.Type

  // MARK: UIViewControllerAnimatedTransitioning

  func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval { 0.25 }

  func animateTransition(using context: UIViewControllerContextTransitioning) {
    guard let fromVC = context.viewController(forKey: .from),
          let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: true),
          let toVC = context.viewController(forKey: .to)
    else {
      context.completeTransition(false)
      return
    }

    context.containerView.addSubview(toVC.view)
    toVC.view.frame = context.containerView.bounds

    let fromView = UIView()
    fromView.tag = Self.fromViewTag
    context.containerView.addSubview(fromView)
    fromView.frame = context.containerView.bounds
    fromView.layer.shadowColor = UIColor.black.cgColor
    fromView.layer.shadowOpacity = 1
    fromView.layer.shadowOffset = .zero
    fromView.layer.shadowRadius = 32
    fromView.addSubview(fromSnapshot)
    fromSnapshot.frame = fromView.bounds
    fromSnapshot.layer.cornerRadius = 0
    fromSnapshot.layer.masksToBounds = true

    dismissInteractor.setup(
      view: fromView,
      action: { fromVC.dismiss(animated: true) }
    )

    viewAnimator.animate(
      withDuration: transitionDuration(using: context),
      animations: {
        self.menuAnimator.animate(in: context.containerView, to: 1)
      },
      completion: { _ in
        let isCancelled = context.transitionWasCancelled
        context.completeTransition(isCancelled == false)
      }
    )
  }
}

import UIKit
import Shared

public protocol UIViewAnimating {
  static func animate(
    withDuration duration: TimeInterval,
    animations: @escaping EmptyClosure,
    completion: ((Bool) -> Void)?
  )
}

extension UIView: UIViewAnimating {}
