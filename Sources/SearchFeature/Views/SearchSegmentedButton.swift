import UIKit
import Shared
import AppResources

final class SearchSegmentedButton: UIControl {
  private let titleLabel = UILabel()
  private let imageView = UIImageView()
  private let highlightColor = Asset.brandPrimary.color
  private let discreteColor = Asset.neutralDisabled.color

  init() {
    super.init(frame: .zero)

    imageView.contentMode = .center
    titleLabel.textAlignment = .center
    titleLabel.font = Fonts.Mulish.semiBold.font(size: 13.0)

    addSubview(titleLabel)
    addSubview(imageView)

    setupConstraints()
  }

  required init?(coder: NSCoder) { nil }

  func setup(title: String, icon: UIImage) {
    imageView.image = icon
    titleLabel.text = title
    imageView.tintColor = discreteColor
    titleLabel.textColor = discreteColor
  }

  func setSelected(_ bool: Bool) {
    imageView.tintColor = bool ? highlightColor : discreteColor
    titleLabel.textColor = bool ? highlightColor : discreteColor
  }

  private func setupConstraints() {
    imageView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(7.5)
      $0.centerX.equalToSuperview()
    }

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(imageView.snp.bottom).offset(2)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-7.5)
    }
  }
}
