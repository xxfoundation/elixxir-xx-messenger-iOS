import UIKit
import Shared

final class RequestReceivedEmptyView: UIView {
    let label = UILabel()
    let icon = UIImageView()
    let stack = UIStackView()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        icon.contentMode = .center
        icon.image = Asset.requestsReceivedPlaceholder.image

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.2
        paragraph.alignment = .center

        label.numberOfLines = 0
        label.attributedText = NSAttributedString(
            string: Localized.Requests.Received.placeholder,
            attributes: [
                .paragraphStyle: paragraph,
                .foregroundColor: Asset.neutralActive.color,
                .font: Fonts.Mulish.bold.font(size: 24.0)
            ]
        )

        stack.axis = .vertical
        stack.spacing = 24
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(label)

        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }
    }
}
