import UIKit
import Shared
import AppResources

final class MenuHeaderView: UIView {
  let textLabel = UILabel()
  let scanButton = UIButton()
  let avatarView = AvatarView()
  let profileButton = UIControl()

  init() {
    super.init(frame: .zero)

    textLabel.numberOfLines = 0
    scanButton.layer.cornerRadius = 14
    avatarView.isUserInteractionEnabled = false
    scanButton.backgroundColor = Asset.neutralBody.color
    scanButton.setImage(Asset.menuScan.image, for: .normal)

    addSubview(scanButton)
    addSubview(profileButton)
    profileButton.addSubview(avatarView)
    profileButton.addSubview(textLabel)

    profileButton.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.right.lessThanOrEqualTo(scanButton.snp.left)
    }
    avatarView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview()
      $0.width.equalTo(70)
      $0.height.equalTo(70)
      $0.bottom.equalToSuperview()
    }
    scanButton.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.right.equalToSuperview()
      $0.width.equalTo(40)
      $0.height.equalTo(40)
    }
    textLabel.snp.makeConstraints {
      $0.centerY.equalTo(avatarView)
      $0.left.equalTo(avatarView.snp.right).offset(20)
      $0.right.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil  }
}
