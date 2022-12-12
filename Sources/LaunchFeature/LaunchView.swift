import UIKit
import AppResources

final class LaunchView: UIView {
  let imageView = UIImageView()
  let gradientLayer = CAGradientLayer.xxGradient()

  init() {
    super.init(frame: .zero)

    imageView.image = Asset.splash.image
    imageView.contentMode = .scaleAspectFit
    backgroundColor = Asset.neutralWhite.color

    addSubview(imageView)

    layer.insertSublayer(gradientLayer, at: 0)

    imageView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.left.equalToSuperview().offset(100)
    }
  }

  required init?(coder: NSCoder) { nil }

  override func layoutSubviews() {
    gradientLayer.frame = bounds
  }
}
