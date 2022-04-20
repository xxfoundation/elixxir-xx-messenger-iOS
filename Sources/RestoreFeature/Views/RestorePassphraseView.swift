import UIKit
import Shared
import InputField

final class RestorePassphraseView: UIView {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let inputField = InputField()
    let stackView = UIStackView()
    let continueButton = CapsuleButton()
    let cancelButton = CapsuleButton()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        layer.cornerRadius = 40
        backgroundColor = Asset.neutralWhite.color
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        subtitleLabel.numberOfLines = 0
        titleLabel.textColor = Asset.neutralActive.color
        subtitleLabel.textColor = Asset.neutralActive.color

        inputField.setup(
            style: .regular,
            title: "Passphrase",
            placeholder: "* * * * * *",
            subtitleColor: Asset.neutralDisabled.color
        )

        titleLabel.text = "Backup password"
        titleLabel.textAlignment = .left
        titleLabel.font = Fonts.Mulish.bold.font(size: 26.0)

        subtitleLabel.text = "Please enter your backup password that you used when you did the backup setup"
        subtitleLabel.textAlignment = .left
        subtitleLabel.font = Fonts.Mulish.regular.font(size: 16.0)

        continueButton.setStyle(.brandColored)
        continueButton.setTitle("Continue", for: .normal)

        cancelButton.setStyle(.seeThrough)
        cancelButton.setTitle("Cancel", for: .normal)

        stackView.spacing = 20
        stackView.axis = .vertical
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(inputField)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(cancelButton)

        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            make.bottom.equalToSuperview().offset(-70)
        }
    }
}
