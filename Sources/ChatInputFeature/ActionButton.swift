import UIKit
import Shared
import AppResources

final class ActionButton: UIControl {
  let titleLabel = UILabel()
  let imageView = UIImageView()
  let imageBackgroundView = UIView()

  init() {
    super.init(frame: .zero)

    imageBackgroundView.layer.cornerRadius = 4
    titleLabel.textColor = Asset.neutralDark.color
    titleLabel.font = Fonts.Mulish.semiBold.font(size: 10.0)
    imageBackgroundView.backgroundColor = Asset.neutralSecondary.color

    addSubview(titleLabel)
    addSubview(imageBackgroundView)
    imageBackgroundView.addSubview(imageView)

    imageView.isUserInteractionEnabled = false
    imageBackgroundView.isUserInteractionEnabled = false

    imageView.snp.makeConstraints { $0.center.equalToSuperview() }

    imageBackgroundView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.width.equalTo(imageBackgroundView.snp.height)
    }

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(imageBackgroundView.snp.bottom).offset(4)
      $0.centerX.equalToSuperview()
      $0.left.greaterThanOrEqualToSuperview()
      $0.bottom.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }

  func setup(title: String, image: UIImage) {
    titleLabel.text = title
    imageView.image = image
  }
}
