import UIKit
import Shared
import AppResources

final class ChatListRecentContactCell: UICollectionViewCell {
  let titleLabel = UILabel()
  let containerView = UIView()
  let avatarView = AvatarView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    contentView.backgroundColor = .white
    
    let newLabel = UILabel()
    newLabel.text = "NEW"
    newLabel.textColor = Asset.neutralWhite.color
    newLabel.font = Fonts.Mulish.bold.font(size: 8.0)
    
    let newContainerView = UIView()
    newContainerView.layer.cornerRadius = 6.0
    newContainerView.layer.masksToBounds = true
    newContainerView.backgroundColor = Asset.accentSafe.color
    
    titleLabel.numberOfLines = 2
    titleLabel.textAlignment = .center
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.textColor = Asset.neutralDark.color
    titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)
    
    contentView.addSubview(titleLabel)
    contentView.addSubview(containerView)
    
    containerView.addSubview(avatarView)
    containerView.addSubview(newContainerView)
    
    newContainerView.addSubview(newLabel)
    
    containerView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
    }
    newContainerView.snp.makeConstraints {
      $0.top.equalTo(containerView.snp.top)
      $0.right.equalTo(containerView.snp.right)
    }
    newLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(3)
      $0.center.equalToSuperview()
      $0.left.equalToSuperview().offset(3)
    }
    avatarView.snp.makeConstraints {
      $0.width.equalTo(48)
      $0.height.equalTo(48)
      $0.top.equalToSuperview().offset(4)
      $0.left.equalToSuperview().offset(4)
      $0.right.equalToSuperview().offset(-4)
      $0.bottom.equalToSuperview().offset(-4)
    }
    titleLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(containerView.snp.bottom).offset(5)
      $0.left.greaterThanOrEqualToSuperview()
      $0.right.lessThanOrEqualToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  required init?(coder: NSCoder) { nil }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
    avatarView.prepareForReuse()
  }
  
  func setup(title: String, image: Data?) {
    titleLabel.text = title
    avatarView.setupProfile(
      title: title,
      image: image,
      size: .large
    )
  }
}
