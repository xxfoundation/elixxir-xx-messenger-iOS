import UIKit
import Shared
import Models
import XXModels

final class ContactAlmostView: UIView {
    // MARK: UI

    let stack = UIStackView()
    let feedback = BottomFeedbackComponent()

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Public

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

    // MARK: Properties

    private func setup() {
        stack.axis = .vertical
        stack.spacing = 25

        addSubview(stack)
        addSubview(feedback)

        setupConstraints()
    }

    private func setupConstraints() {
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }

        feedback.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(stack.snp.bottom).offset(24)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
