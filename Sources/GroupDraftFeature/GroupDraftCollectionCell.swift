import UIKit
import Shared
import Combine
import AppResources

final class GroupDraftCollectionCell: UICollectionViewCell {
  let titleLabel = UILabel()
  let removeButton = UIButton()
  let upperView = UIView()
  let avatarView = AvatarView()
  
  var didTapRemove: (() -> Void)?
  var cancellables = Set<AnyCancellable>()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    titleLabel.numberOfLines = 2
    titleLabel.lineBreakMode = .byWordWrapping
    titleLabel.textAlignment = .center
    titleLabel.textColor = Asset.neutralDark.color
    titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)
    
    removeButton.layer.cornerRadius = 9
    removeButton.backgroundColor = Asset.accentDanger.color
    removeButton.setImage(Asset.contactListAvatarRemove.image, for: .normal)
    
    upperView.addSubview(avatarView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(upperView)
    contentView.addSubview(removeButton)
    
    upperView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
    }
    
    avatarView.snp.makeConstraints {
      $0.width.equalTo(48)
      $0.height.equalTo(48)
      $0.top.equalToSuperview().offset(4)
      $0.left.equalToSuperview().offset(4)
      $0.right.equalToSuperview().offset(-4)
      $0.bottom.equalToSuperview().offset(-4)
    }
    
    removeButton.snp.makeConstraints {
      $0.centerY.equalTo(avatarView.snp.top).offset(5)
      $0.centerX.equalTo(avatarView.snp.right).offset(-5)
      $0.width.equalTo(18)
      $0.height.equalTo(18)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(upperView.snp.bottom)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }
  
  required init?(coder: NSCoder) { nil }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
    avatarView.prepareForReuse()
    cancellables.removeAll()
  }
  
  func setup(title: String, image: Data?) {
    titleLabel.text = title
    avatarView.setupProfile(title: title, image: image, size: .large)
    cancellables.removeAll()
    
    removeButton
      .publisher(for: .touchUpInside)
      .sink { [unowned self] in
        didTapRemove?()
      }.store(in: &cancellables)
  }
}
