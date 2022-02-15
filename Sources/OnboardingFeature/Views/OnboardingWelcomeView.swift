import UIKit
import Shared

final class OnboardingWelcomeView: UIView {
    let titleLabel = UILabel()
    let subtitleView = TextWithInfoView()
    let stackView = UIStackView()
    let continueButton = CapsuleButton()
    let skipButton = CapsuleButton()

    var didTapInfo: (() -> Void)?

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralWhite.color

        setupSubtitle(Localized.Onboarding.Welcome.subtitle)

        skipButton.set(style: .brandColored, title: Localized.Onboarding.Welcome.skip)
        continueButton.set(style: .brandColored, title: Localized.Onboarding.Welcome.continue)

        stackView.spacing = 15
        stackView.axis = .vertical
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(skipButton)

        addSubview(titleLabel)
        addSubview(subtitleView)
        addSubview(stackView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(30)
            make.left.equalToSuperview().offset(38)
            make.right.equalToSuperview().offset(-41)
        }

        subtitleView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(38)
            make.right.equalToSuperview().offset(-41)
        }

        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-50)
        }
    }

    required init?(coder: NSCoder) { nil }

    func setupTitle(_ title: String) {
        let attString = NSMutableAttributedString(string: title)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineHeightMultiple = 1.1

        attString.addAttribute(.paragraphStyle, value: paragraph)
        attString.addAttribute(.foregroundColor, value: Asset.neutralActive.color)
        attString.addAttribute(.font, value: Fonts.Mulish.bold.font(size: 34.0) as Any)

        attString.addAttributes(attributes: [
            .font: Fonts.Mulish.bold.font(size: 34.0) as Any,
            .foregroundColor: Asset.brandPrimary.color
        ], betweenCharacters: "#")

        titleLabel.numberOfLines = 0
        titleLabel.attributedText = attString
    }

    private func setupSubtitle(_ subtitle: String) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineHeightMultiple = 1.15

        subtitleView.setup(
            text: subtitle,
            attributes: [
                .foregroundColor: Asset.neutralBody.color,
                .font: Fonts.Mulish.regular.font(size: 16.0) as Any,
                .paragraphStyle: paragraph
            ],
            didTapInfo: { [weak self] in self?.didTapInfo?() }
        )
    }
}
