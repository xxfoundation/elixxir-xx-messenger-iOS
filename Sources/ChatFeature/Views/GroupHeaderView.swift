import UIKit
import Shared
import AppResources

final class GroupHeaderView: UIView {
  let titleLabel = UILabel()
  let avatarStackView = UIStackView()

  init() {
    super.init(frame: .zero)

    avatarStackView.spacing = -5
    titleLabel.textColor = Asset.neutralActive.color
    titleLabel.font = Fonts.Mulish.semiBold.font(size: 15.0)

    addSubview(titleLabel)
    addSubview(avatarStackView)

    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.centerX.equalToSuperview()
      $0.left.greaterThanOrEqualToSuperview()
      $0.right.lessThanOrEqualToSuperview()
    }

    avatarStackView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.centerX.equalToSuperview()
      $0.left.greaterThanOrEqualToSuperview()
      $0.right.lessThanOrEqualToSuperview()
      $0.bottom.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }
}
