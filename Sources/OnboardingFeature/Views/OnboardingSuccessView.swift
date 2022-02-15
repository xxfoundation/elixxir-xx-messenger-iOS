import UIKit
import Shared

final class OnboardingSuccessView: UIView {
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let nextButton = CapsuleButton()

    init() {
        super.init(frame: .zero)

        iconImageView.contentMode = .center
        iconImageView.image = Asset.onboardingSuccess.image
        nextButton.set(style: .white, title: Localized.Onboarding.Success.action)

        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(nextButton)

        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(40)
            make.left.equalToSuperview().offset(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-90)
        }

        nextButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-60)
        }
    }

    required init?(coder: NSCoder) { nil }

    func set(type: String) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineHeightMultiple = 1.1

        let attrString = NSMutableAttributedString(
            string: Localized.Onboarding.Success.title(type.lowercased())
        )

        attrString.addAttribute(.font, value: Fonts.Mulish.bold.font(size: 39.0))
        attrString.addAttribute(.foregroundColor, value: Asset.neutralWhite.color)

        attrString.addAttribute(
            name: .foregroundColor,
            value: Asset.neutralBody.color,
            betweenCharacters: "#"
        )

        titleLabel.numberOfLines = 0
        titleLabel.attributedText = attrString
    }
}
