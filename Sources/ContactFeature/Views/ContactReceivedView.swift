import UIKit
import Shared

final class ContactReceivedView: UIView {
    // MARK: UI

    let title = UILabel()
    let icon = UIImageView()
    let stack = UIStackView()
    let accept = CapsuleButton()
    let reject = CapsuleButton()

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    //  MARK: Private

    private func setup() {
        icon.contentMode = .center

        title.textAlignment = .center
        title.textColor = Asset.neutralBody.color
        title.text = Localized.Contact.Received.title
        title.font = Fonts.Mulish.bold.font(size: 24.0)

        icon.image = Asset.contactRequestPlaceholder.image

        accept.setStyle(.brandColored)
        accept.setTitle(Localized.Contact.Received.accept, for: .normal)

        reject.setStyle(.seeThrough)
        reject.setTitle(Localized.Contact.Received.reject, for: .normal)

        stack.axis = .vertical
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(accept)
        stack.addArrangedSubview(reject)

        stack.setCustomSpacing(24, after: title)
        stack.setCustomSpacing(20, after: accept)

        addSubview(icon)
        addSubview(stack)

        setupConstraints()
    }

    private func setupConstraints() {
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(stack.snp.top).offset(-30)
        }

        stack.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(20)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-34)
        }
    }
}
