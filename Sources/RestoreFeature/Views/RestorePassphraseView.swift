import UIKit
import Shared
import InputField
import AppResources

final class RestorePassphraseView: UIView {
  let titleLabel = UILabel()
  let subtitleLabel = UILabel()
  let inputField = InputField()
  let stackView = UIStackView()
  let continueButton = CapsuleButton()
  let cancelButton = CapsuleButton()

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
      contentType: .password
    )
  }

  private func setupLabels() {
    titleLabel.textAlignment = .left
    titleLabel.textColor = Asset.neutralActive.color
    titleLabel.font = Fonts.Mulish.bold.font(size: 26.0)
    titleLabel.text = Localized.Backup.Restore.Passphrase.title

    subtitleLabel.numberOfLines = 0
    subtitleLabel.textAlignment = .left
    subtitleLabel.textColor = Asset.neutralActive.color
    subtitleLabel.font = Fonts.Mulish.regular.font(size: 16.0)
    subtitleLabel.text = Localized.Backup.Restore.Passphrase.subtitle
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
