import UIKit
import Shared
import XXModels
import AppResources

final class ContactAlmostView: UIView {
  let stack = UIStackView()
  let feedback = BottomFeedbackComponent()

  init() {
    super.init(frame: .zero)
    stack.axis = .vertical
    stack.spacing = 25

    addSubview(stack)
    addSubview(feedback)

    stack.snp.makeConstraints {
      $0.top.equalToSuperview().offset(24)
      $0.left.equalToSuperview().offset(24)
      $0.right.equalToSuperview().offset(-24)
    }

    feedback.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(stack.snp.bottom).offset(24)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }

  func set(status: Contact.AuthStatus) {
    switch status {
    case .requestFailed, .confirmationFailed:
      feedback.set(
        icon: Asset.contactRequestExclamation.image,
        title: Localized.Contact.Inprogress.failed,
        style: .danger,
        actionTitle: Localized.Contact.Inprogress.resend
      )

    case .confirming, .requested, .requesting:
      feedback.set(
        icon: Asset.contactRequestExclamation.image,
        title: Localized.Contact.Inprogress.pending,
        style: .chill
      )
    default:
      break
    }
  }
}
