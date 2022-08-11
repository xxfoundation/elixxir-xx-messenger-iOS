import UIKit
import Shared

final class TermsConditionsView: UIView {
    let titleLabel = UILabel()
    let nextButton = CapsuleButton()
    let showTermsButton = CapsuleButton()
    let radioComponent = RadioTextComponent()

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralWhite.color

        let attString = NSMutableAttributedString(string: Localized.Terms.title)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineHeightMultiple = 1.15

        attString.addAttribute(.paragraphStyle, value: paragraph)
        attString.addAttribute(.foregroundColor, value: Asset.neutralActive.color)
        attString.addAttribute(.font, value: Fonts.Mulish.bold.font(size: 34.0) as Any)

        attString.addAttributes(attributes: [
            .font: Fonts.Mulish.bold.font(size: 34.0) as Any,
            .foregroundColor: Asset.brandPrimary.color
        ], betweenCharacters: "#")

        titleLabel.numberOfLines = 0
        titleLabel.attributedText = attString

        radioComponent.titleLabel.text = Localized.Terms.radio

        nextButton.isEnabled = false
        nextButton.set(style: .brandColored, title: Localized.Terms.accept)
        showTermsButton.set(style: .seeThrough, title: Localized.Terms.show)

        addSubview(titleLabel)
        addSubview(nextButton)
        addSubview(radioComponent)
        addSubview(showTermsButton)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(30)
            $0.left.equalToSuperview().offset(38)
            $0.right.equalToSuperview().offset(-44)
        }

        radioComponent.snp.makeConstraints {
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
            $0.bottom.equalTo(nextButton.snp.top).offset(-20)
        }

        nextButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
            $0.bottom.equalTo(showTermsButton.snp.top).offset(-10)
        }

        showTermsButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-40)
        }
    }
}
