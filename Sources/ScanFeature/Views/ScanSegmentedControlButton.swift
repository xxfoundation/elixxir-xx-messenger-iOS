import UIKit
import Shared
import AppResources

final class ScanSegmentedControlButton: UIControl {
  let titleLabel = UILabel()
  let separatorView = UIView()
  let imageView = UIImageView()

  init() {
    super.init(frame: .zero)

    separatorView.alpha = 0.0
    titleLabel.textAlignment = .center
    imageView.tintColor = Asset.neutralWeak.color
    titleLabel.textColor = Asset.neutralWeak.color
    separatorView.backgroundColor = Asset.neutralWhite.color
    titleLabel.font = Fonts.Mulish.semiBold.font(size: 13)
    imageView.transform = imageView.transform.scaledBy(x: 0.9, y: 0.9)
    titleLabel.transform = titleLabel.transform.scaledBy(x: 0.9, y: 0.9)

    addSubview(titleLabel)
    addSubview(imageView)
    addSubview(separatorView)

    imageView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(7.5)
      $0.centerX.equalToSuperview()
    }

    titleLabel.snp.makeConstraints {
      $0.top.equalTo(imageView.snp.bottom).offset(2)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-7.5)
    }

    separatorView.snp.makeConstraints {
      $0.height.equalTo(2)
      $0.left.equalToSuperview().offset(20)
      $0.right.equalToSuperview().offset(-20)
      $0.bottom.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }

  func set(selected: Bool) {
    switch (isSelected, selected) {
    case (true, false):
      UIView.animate(withDuration: 0.25) {
        self.imageView.transform = self.imageView.transform.scaledBy(x: 0.9, y: 0.9)
        self.titleLabel.transform = self.titleLabel.transform.scaledBy(x: 0.9, y: 0.9)
        self.imageView.tintColor = Asset.neutralWeak.color
        self.titleLabel.textColor = Asset.neutralWeak.color
        self.separatorView.alpha = 0.0
      } completion: { _ in
        self.isSelected = false
      }

    case (false, true):
      UIView.animate(withDuration: 0.25) {
        self.imageView.transform = .identity
        self.titleLabel.transform = .identity
        self.imageView.tintColor = Asset.neutralWhite.color
        self.titleLabel.textColor = Asset.neutralWhite.color
        self.separatorView.alpha = 1.0
      } completion: { _ in
        self.isSelected = true
      }
    case (true, true), (false, false):
      break
    }
  }
}
