import UIKit

protocol LeftAnimating {
  func animate(in containerView: UIView, to progress: CGFloat)
}

struct LeftAnimator: LeftAnimating {
  func animate(in containerView: UIView, to progress: CGFloat) {
    guard let fromView = containerView.viewWithTag(LeftPresentTransition.fromViewTag) else { return }

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
