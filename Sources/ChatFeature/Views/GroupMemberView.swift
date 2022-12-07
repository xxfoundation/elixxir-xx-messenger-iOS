import UIKit
import Shared
import AppResources

final class GroupMemberView: UIView {
  let titleLabel = UILabel()
  let avatarView = AvatarView()
  let separatorView = UIView()

  init() {
    super.init(frame: .zero)
    backgroundColor = Asset.neutralWhite.color
    titleLabel.textColor = Asset.neutralBody.color
    titleLabel.font = Fonts.Mulish.bold.font(size: 12.0)
    separatorView.backgroundColor = Asset.neutralLine.color

    addSubview(titleLabel)
    addSubview(avatarView)
    addSubview(separatorView)

    avatarView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(10)
      $0.width.height.equalTo(30)
      $0.left.equalToSuperview().offset(25)
      $0.centerY.equalToSuperview()
    }

    titleLabel.snp.makeConstraints {
      $0.centerY.equalTo(avatarView)
      $0.left.equalTo(avatarView.snp.right).offset(14)
      $0.right.lessThanOrEqualToSuperview().offset(-10)
    }

    separatorView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.left.equalToSuperview().offset(25)
      $0.right.equalToSuperview().offset(-25)
      $0.bottom.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }
}
