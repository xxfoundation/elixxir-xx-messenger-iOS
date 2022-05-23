import UIKit
import Shared
import InputField

final class NicknameView: UIView {
    let titleLabel = UILabel()
    let imageView = UIImageView()
    let inputField = InputField()
    let stackView = UIStackView()
    let saveButton = CapsuleButton()

    init() {
        super.init(frame: .zero)

        layer.cornerRadius = 40
        backgroundColor = Asset.neutralWhite.color
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        imageView.contentMode = .center
        titleLabel.textColor = Asset.neutralDark.color
        imageView.image = Asset.personPlaceholder.image

        inputField.setup(
            style: .regular,
            title: Localized.Contact.Nickname.input,
            placeholder: "Jim Morrison",
            leftView: .image(Asset.personGray.image),
            subtitleColor: Asset.neutralDisabled.color
        )

        titleLabel.text = Localized.Contact.Nickname.title
        titleLabel.textAlignment = .center
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 18.0)

        saveButton.setStyle(.brandColored)
        saveButton.setTitle(Localized.Contact.Nickname.save, for: .normal)

        stackView.spacing = 20
        stackView.axis = .vertical
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(inputField)
        stackView.addArrangedSubview(saveButton)

        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.left.equalToSuperview().offset(30)
            $0.right.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview().offset(-40)
        }
    }

    required init?(coder: NSCoder) { nil }

    func update(status: InputField.ValidationStatus) {
        inputField.update(status: status)

        switch status {
        case .valid:
            saveButton.isEnabled = true
        case .invalid, .unknown:
            saveButton.isEnabled = false
        }
    }
}
