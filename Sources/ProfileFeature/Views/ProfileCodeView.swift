import UIKit
import Shared
import InputField
import AppResources

final class ProfileCodeView: UIView {
    let titleLabel = UILabel()
    let resendButton = UIButton()
    let subtitleLabel = UILabel()
    let iconImageView = UIImageView()
    let stackView = UIStackView()
    let inputField = InputField()
    let saveButton = CapsuleButton()

    init() {
        super.init(frame: .zero)

        iconImageView.contentMode = .center
        subtitleLabel.numberOfLines = 0

        titleLabel.text = Localized.Profile.Code.title
        titleLabel.font = Fonts.Mulish.bold.font(size: 32.0)
        titleLabel.textColor = Asset.neutralActive.color

        resendButton.setTitleColor(Asset.brandPrimary.color, for: .normal)
        resendButton.setTitleColor(Asset.neutralWeak.color, for: .disabled)
        resendButton.setTitle(Localized.Profile.Code.resend(""), for: .normal)
        resendButton.titleLabel?.font = Fonts.Mulish.semiBold.font(size: 14.0)

        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.addArrangedSubview(saveButton)
        stackView.addArrangedSubview(resendButton)

        saveButton.set(style: .brandColored, title: Localized.Profile.Code.action)

        inputField.setup(
            allowsEmptySpace: false,
            keyboardType: .numberPad,
            autocapitalization: .none,
            contentType: .oneTimeCode,
            clearable: true
        )

        addSubview(iconImageView)
        addSubview(inputField)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(stackView)

        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(34)
            make.centerX.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
        }

        inputField.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }

        stackView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(inputField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-44)
        }
    }

    func set(_ content: String, isEmail: Bool) {
        let text = Localized.Profile.Code.subtitle(content)

        let attString = NSMutableAttributedString(string: text)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineHeightMultiple = 1.1

        attString.addAttribute(.font, value: Fonts.Mulish.regular.font(size: 16.0) as Any)
        attString.addAttribute(.foregroundColor, value: Asset.neutralActive.color)
        attString.addAttribute(.paragraphStyle, value: paragraph)

        subtitleLabel.attributedText = attString

        if isEmail {
            iconImageView.image = Asset.profileEmail.image
        } else {
            iconImageView.image = Asset.profilePhone.image
        }
    }

    required init?(coder: NSCoder) { nil }
}
