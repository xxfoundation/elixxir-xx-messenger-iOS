import UIKit
import Shared
import AppResources

final class RequestPermissionView: UIView {
  let titleLabel = UILabel()
  let iconImage = UIImageView()
  let subtitleLabel = UILabel()
  let littleLogo = UIImageView()
  let notNowButton = UIButton()
  let continueButton = CapsuleButton()

  init() {
    super.init(frame: .zero)
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

    iconImage.snp.makeConstraints {
      $0.centerX.equalToSuperview()
    }

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(iconImage.snp.bottom).offset(34)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
    }

    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
      $0.left.equalToSuperview().offset(32)
      $0.right.equalToSuperview().offset(-32)
      $0.bottom.equalTo(snp.centerY)
    }

    littleLogo.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(safeAreaLayoutGuide).offset(-15)
    }

    actionsContainer.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(subtitleLabel.snp.bottom)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.lessThanOrEqualTo(littleLogo.snp.top)
    }

    continueButton.snp.makeConstraints {
      $0.top.greaterThanOrEqualToSuperview()
      $0.left.equalToSuperview().offset(24)
      $0.right.equalToSuperview().offset(-24)
      $0.bottom.equalTo(actionsContainer.snp.centerY).offset(-5)
    }

    notNowButton.snp.makeConstraints {
      $0.top.equalTo(actionsContainer.snp.centerY).offset(5)
      $0.left.equalToSuperview().offset(24)
      $0.right.equalToSuperview().offset(-24)
      $0.bottom.lessThanOrEqualToSuperview()
    }
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
}
