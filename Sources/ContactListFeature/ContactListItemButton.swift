import UIKit
import Shared
import AppResources

final class ItemButton: UIControl {
  let titleLabel = UILabel()
  let iconImageView = UIImageView()
  let separatorView = UIView()
  let stackView = UIStackView()
  let notificationLabel = UILabel()

  init() {
    super.init(frame: .zero)

    titleLabel.textColor = Asset.brandPrimary.color
    titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)
    separatorView.backgroundColor = Asset.neutralLine.color

    notificationLabel.isHidden = true
    notificationLabel.layer.cornerRadius = 5
    notificationLabel.layer.masksToBounds = true
    notificationLabel.textColor = Asset.neutralWhite.color
    notificationLabel.backgroundColor = Asset.brandPrimary.color
    notificationLabel.font = Fonts.Mulish.bold.font(size: 12.0)
    
    stackView.spacing = 16
    stackView.addArrangedSubview(iconImageView)
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(notificationLabel)
    stackView.setCustomSpacing(6, after: titleLabel)

    stackView.isUserInteractionEnabled = false
    addSubview(stackView)
    addSubview(separatorView)

    stackView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(12)
      make.left.equalToSuperview().offset(24)
      make.bottom.equalTo(separatorView.snp.top).offset(-12)
    }

    separatorView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalToSuperview()
      make.height.equalTo(1)
    }
  }

  required init?(coder: NSCoder) { nil }

  func setup(title: String, image: UIImage) {
    titleLabel.text = title
    iconImageView.image = image
  }

  func updateNotification(_ count: Int) {
    notificationLabel.isHidden = count < 1
    notificationLabel.text = "  \(count)  "
  }
}
