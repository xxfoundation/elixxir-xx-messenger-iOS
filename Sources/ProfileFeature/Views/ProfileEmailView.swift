import UIKit
import Shared
import InputField
import AppResources

final class ProfileEmailView: UIView {
  let titleLabel = UILabel()
  let imageView = UIImageView()
  let inputField = InputField()
  let saveButton = CapsuleButton()

  init() {
    super.init(frame: .zero)

    titleLabel.text = Localized.Profile.EmailScreen.title
    titleLabel.textAlignment = .center
    titleLabel.textColor = Asset.neutralActive.color
    titleLabel.font = Fonts.Mulish.bold.font(size: 32.0)
    imageView.contentMode = .center
    imageView.image = Asset.profileEmail.image
    saveButton.setStyle(.brandColored)
    saveButton.setTitle(Localized.Profile.EmailScreen.action, for: .normal)

    inputField.setup(
      title: Localized.Profile.EmailScreen.input,
      placeholder: Localized.Profile.EmailScreen.input,
      subtitleColor: Asset.neutralWeak.color,
      allowsEmptySpace: false,
      keyboardType: .emailAddress,
      autocapitalization: .none,
      contentType: .emailAddress
    )

    addSubview(imageView)
    addSubview(titleLabel)
    addSubview(inputField)
    addSubview(saveButton)

    imageView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(60)
      make.centerX.equalToSuperview()
    }

    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(39)
      make.centerX.equalToSuperview()
    }

    inputField.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(35)
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
    }

    saveButton.snp.makeConstraints { make in
      make.top.greaterThanOrEqualTo(inputField.snp.bottom).offset(40)
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalTo(safeAreaLayoutGuide).offset(-40)
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
