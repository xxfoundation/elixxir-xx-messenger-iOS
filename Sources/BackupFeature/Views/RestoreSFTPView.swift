import UIKit
import Shared
import InputField

final class BackupSFTPView: UIView {
  let titleLabel = UILabel()
  let subtitleLabel = UILabel()
  let hostField = OutlinedInputField()
  let usernameField = OutlinedInputField()
  let passwordField = OutlinedInputField()
  let loginButton = CapsuleButton()
  let stackView = UIStackView()

  init() {
    super.init(frame: .zero)
    backgroundColor = Asset.neutralWhite.color

    titleLabel.textColor = Asset.neutralDark.color
    titleLabel.text = Localized.AccountRestore.Sftp.title
    titleLabel.font = Fonts.Mulish.bold.font(size: 24.0)

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .left
    paragraph.lineHeightMultiple = 1.15

    let attString = NSMutableAttributedString(
      string: Localized.AccountRestore.Sftp.subtitle,
      attributes: [
        .foregroundColor: Asset.neutralBody.color,
        .font: Fonts.Mulish.regular.font(size: 16.0) as Any,
        .paragraphStyle: paragraph
      ])

    attString.setAttributes(
      attributes: [
        .foregroundColor: Asset.neutralDark.color,
        .font: Fonts.Mulish.bold.font(size: 12.0) as Any,
        .paragraphStyle: paragraph
      ], betweenCharacters: "*")

    subtitleLabel.numberOfLines = 0
    subtitleLabel.attributedText = attString

    hostField.setup(title: Localized.AccountRestore.Sftp.host)
    usernameField.setup(title: Localized.AccountRestore.Sftp.username)
    passwordField.setup(title: Localized.AccountRestore.Sftp.password, sensitive: true)

    loginButton.set(style: .brandColored, title: Localized.AccountRestore.Sftp.login)

    stackView.spacing = 30
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.addArrangedSubview(hostField)
    stackView.addArrangedSubview(usernameField)
    stackView.addArrangedSubview(passwordField)
    stackView.addArrangedSubview(loginButton)

    addSubview(titleLabel)
    addSubview(subtitleLabel)
    addSubview(stackView)

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(safeAreaLayoutGuide).offset(15)
      $0.left.equalToSuperview().offset(38)
      $0.right.equalToSuperview().offset(-41)
    }

    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
      $0.left.equalToSuperview().offset(38)
      $0.right.equalToSuperview().offset(-41)
    }

    stackView.snp.makeConstraints {
      $0.top.equalTo(subtitleLabel.snp.bottom).offset(28)
      $0.left.equalToSuperview().offset(38)
      $0.right.equalToSuperview().offset(-38)
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }
}
