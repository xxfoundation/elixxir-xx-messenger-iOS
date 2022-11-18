import UIKit
import Shared
import AppResources

final class ContactScannedView: UIView {
    let title = UILabel()
    let subtitle = UILabel()
    let stack = UIStackView()
    let add = CapsuleButton()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        title.textAlignment = .center
        title.text = Localized.Contact.Scanned.title
        title.textColor = Asset.neutralBody.color
        title.font = Fonts.Mulish.bold.font(size: 24.0)

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineHeightMultiple = 1.35

        subtitle.numberOfLines = 0
        subtitle.attributedText = NSAttributedString(
            string: Localized.Contact.Scanned.subtitle,
            attributes: [
                .paragraphStyle: paragraph,
                .foregroundColor: Asset.neutralWeak.color,
                .font: Fonts.Mulish.semiBold.font(size: 14.0) as Any
            ]
        )

        add.setStyle(.brandColored)
        add.setTitle(Localized.Contact.Scanned.action, for: .normal)

        stack.spacing = 10
        stack.axis = .vertical
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(subtitle)
        stack.addArrangedSubview(UIView())
        stack.addArrangedSubview(add)
        stack.addArrangedSubview(UIView())
        addSubview(stack)

        setupConstraints()
    }

    private func setupConstraints() {
        stack.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(20)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-34)
        }
    }
}
