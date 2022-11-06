import UIKit
import Shared

final class LaunchView: UIView {
  let imageView = UIImageView()

  init() {
    super.init(frame: .zero)
    imageView.image = Asset.splash.image
    imageView.contentMode = .scaleAspectFit
    backgroundColor = Asset.neutralWhite.color
    addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.left.equalToSuperview().offset(100)
    }
  }

  required init?(coder: NSCoder) { nil }
}
