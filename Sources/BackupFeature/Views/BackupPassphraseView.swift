import UIKit
import Shared
import InputField

final class BackupPassphraseView: UIView {
    let titleLabel = UILabel()
    let stackView = UIStackView()
    let inputField = InputField()
    let subtitleLabel = UILabel()
    let cancelButton = CapsuleButton()
    let continueButton = CapsuleButton()

    init() {
        super.init(frame: .zero)
        layer.cornerRadius = 40
        backgroundColor = Asset.neutralWhite.color
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        setupInput()
        setupLabels()
        setupButtons()
        setupStackView()
    }

    required init?(coder: NSCoder) { nil }

    private func setupInput() {
        inputField.setup(
            style: .regular,
            title: Localized.Backup.Passphrase.Input.title,
            placeholder: Localized.Backup.Passphrase.Input.placeholder,
            rightView: .toggleSecureEntry,
            subtitleColor: Asset.neutralDisabled.color,
            allowsEmptySpace: false,
            autocapitalization: .none,
            contentType: .newPassword
        )
    }

    private func setupLabels() {
        titleLabel.textAlignment = .left
        titleLabel.text = Localized.Backup.Passphrase.title
        titleLabel.textColor = Asset.neutralActive.color
        titleLabel.font = Fonts.Mulish.bold.font(size: 26.0)

        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = Asset.neutralActive.color
        subtitleLabel.text = Localized.Backup.Passphrase.subtitle
        subtitleLabel.font = Fonts.Mulish.regular.font(size: 16.0)
    }

    private func setupButtons() {
        cancelButton.setStyle(.seeThrough)
        cancelButton.setTitle(Localized.Backup.Passphrase.cancel, for: .normal)

        continueButton.isEnabled = false
        continueButton.setStyle(.brandColored)
        continueButton.setTitle(Localized.Backup.Passphrase.continue, for: .normal)
    }

    private func setupStackView() {
        stackView.spacing = 20
        stackView.axis = .vertical
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(inputField)
        stackView.addArrangedSubview(continueButton)
        stackView.addArrangedSubview(cancelButton)

        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.left.equalToSuperview().offset(50)
            $0.right.equalToSuperview().offset(-50)
            $0.bottom.equalToSuperview().offset(-70)
        }
    }
}
