import UIKit

protocol LeftDismissInteracting: UIViewControllerInteractiveTransitioning {
  var interactionInProgress: Bool { get }
  func setup(view: UIView, action: @escaping (() -> Void))
}

final class LeftDismissInteractor:
  UIPercentDrivenInteractiveTransition, LeftDismissInteracting {
  private var action: (() -> Void)?
  public var interactionInProgress = false
  private var shouldFinishTransition = false

  func setup(view: UIView, action: @escaping (() -> Void)) {
    view.addGestureRecognizer(UIPanGestureRecognizer(
      target: self,
      action: #selector(handlePanGesture(_:))
    ))
    view.addGestureRecognizer(UITapGestureRecognizer(
      target: self,
      action: #selector(handleTapGesture(_:))
    ))
    self.action = action
  }

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
