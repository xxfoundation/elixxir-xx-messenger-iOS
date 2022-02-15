import UIKit
import Shared

final class RequestPermissionView: UIView {
    let titleLabel = UILabel()
    let iconImage = UIImageView()
    let subtitleLabel = UILabel()
    let littleLogo = UIImageView()
    private(set) var notNowButton = UIButton()
    private(set) var continueButton = CapsuleButton()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    func setup(title: String, subtitle: String, image: UIImage) {
        iconImage.image = image
        titleLabel.text = title

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.5
        paragraph.alignment = .center

        subtitleLabel.attributedText = NSAttributedString(
            string: subtitle,
            attributes: [
                .paragraphStyle: paragraph,
                .font: Fonts.Mulish.regular.font(size: 14.0),
                .foregroundColor: Asset.neutralBody.color,
            ]
        )
    }

    private func setup() {
        littleLogo.image = Asset.permissionLogo.image
        notNowButton.setTitle(Localized.Chat.Actions.Permission.notnow, for: .normal)
        continueButton.set(style: .brandColored, title: Localized.Chat.Actions.Permission.continue)

        titleLabel.textAlignment = .center

        backgroundColor = Asset.neutralWhite.color
        titleLabel.textColor = Asset.neutralActive.color
        notNowButton.setTitleColor(Asset.neutralWeak.color, for: .normal)

        subtitleLabel.numberOfLines = 0

        titleLabel.font = Fonts.Mulish.bold.font(size: 24.0)
        notNowButton.titleLabel?.font = Fonts.Mulish.semiBold.font(size: 16)

        let actionsContainer = UIView()
        actionsContainer.addSubview(continueButton)
        actionsContainer.addSubview(notNowButton)

        addSubview(iconImage)
        addSubview(titleLabel)
        addSubview(littleLogo)
        addSubview(subtitleLabel)
        addSubview(actionsContainer)

        iconImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImage.snp.bottom).offset(34)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.bottom.equalTo(snp.centerY)
        }

        littleLogo.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-15)
        }

        actionsContainer.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(subtitleLabel.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.lessThanOrEqualTo(littleLogo.snp.top)
        }

        continueButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(actionsContainer.snp.centerY).offset(-5)
        }

        notNowButton.snp.makeConstraints { make in
            make.top.equalTo(actionsContainer.snp.centerY).offset(5)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}
