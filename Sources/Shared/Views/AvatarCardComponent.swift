import UIKit
import AppResources

public final class AvatarCardComponent: UIView {
  public let nameLabel = UILabel()
  public let stackView = UIStackView()
  public let avatarView = EditableAvatarView()
  public var nameContainer: UIView?
  private let sendMessageView = AvatarSendMessageView()
  
  public var image: UIImage? {
    didSet {
      avatarView.imageView.image = nil
      avatarView.imageView.image = image
      avatarView.imageView.setNeedsDisplay()
      avatarView.placeholderImageView.image = nil
    }
  }
  
  public init() {
    super.init(frame: .zero)
    
    backgroundColor = Asset.neutralBody.color
    
    nameLabel.textColor = Asset.neutralWhite.color
    nameLabel.numberOfLines = 2
    nameLabel.textAlignment = .center
    nameLabel.font = Fonts.Mulish.bold.font(size: 24.0)
    
    nameContainer = nameLabel.pinning(at: .center(0))
    let imageContainer = avatarView.pinning(at: .hCenter)
    
    stackView.axis = .vertical
    stackView.addArrangedSubview(imageContainer)
    stackView.addArrangedSubview(nameContainer ?? UIView())
    stackView.setCustomSpacing(24, after: imageContainer)
    
    addSubview(stackView)
    
    nameLabel.snp.makeConstraints { make in
      make.top.bottom.centerX.equalToSuperview()
      make.left.greaterThanOrEqualToSuperview().offset(10)
      make.right.lessThanOrEqualToSuperview().offset(-10)
    }
    
    stackView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(40)
      make.left.equalToSuperview().offset(16)
      make.right.equalToSuperview().offset(-16)
      make.bottom.equalToSuperview().offset(-30)
    }
  }
  
  required init?(coder: NSCoder) { nil }
  
  public func setupButtons(
    info: @escaping () -> Void,
    send: @escaping () -> Void
  ) {
    let container = UIView()
    container.addSubview(sendMessageView)
    
    sendMessageView.didTapInfo = info
    sendMessageView.didTapSend = send
    
    sendMessageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.greaterThanOrEqualToSuperview()
      make.centerX.equalToSuperview()
      make.right.lessThanOrEqualToSuperview()
      make.bottom.equalToSuperview()
    }
    
    if let nameContainer = nameContainer {
      stackView.addArrangedSubview(container)
      stackView.setCustomSpacing(48, after: nameContainer)
    }
  }
}

private final class AvatarSendMessageView: UIView {
  let stackView = UIStackView()
  let iconImageView = UIImageView()
  let sendButton = UIButton()
  let infoButton = UIButton()
  
  var didTapInfo: (() -> Void)?
  var didTapSend: (() -> Void)?
  
  init() {
    super.init(frame: .zero)
    
    iconImageView.contentMode = .center
    iconImageView.image = Asset.contactSendMessage.image
    
    sendButton.setTitle("Send Message", for: .normal)
    sendButton.setTitleColor(Asset.brandPrimary.color, for: .normal)
    sendButton.titleLabel?.font = Fonts.Mulish.regular.font(size: 13.0)
    
    infoButton.setImage(Asset.infoIconGrey.image, for: .normal)
    
    sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    infoButton.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
    
    stackView.spacing = 8
    stackView.distribution = .equalSpacing
    stackView.addArrangedSubview(iconImageView)
    stackView.addArrangedSubview(sendButton)
    stackView.addArrangedSubview(infoButton)
    
    addSubview(stackView)
    stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
  }
  
  required init?(coder: NSCoder) { nil }
  
  @objc private func didTapSendButton() {
    didTapSend?()
  }
  
  @objc private func didTapInfoButton() {
    didTapInfo?()
  }
}

public final class EditableAvatarView: UIView {
  public let editButton = UIButton()
  public let imageView = UIImageView()
  public let placeholderImageView = UIImageView()
  
  init() {
    super.init(frame: .zero)
    
    imageView.layer.cornerRadius = 38
    imageView.layer.masksToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = Asset.brandPrimary.color
    
    placeholderImageView.contentMode = .center
    placeholderImageView.image = Asset.profileImagePlaceholder.image
    
    editButton.setImage(Asset.profileImageButton.image, for: .normal)
    
    addSubview(imageView)
    addSubview(editButton)
    imageView.addSubview(placeholderImageView)
    
    editButton.snp.makeConstraints { make in
      make.bottom.equalTo(imageView)
      make.right.equalTo(imageView).offset(9)
    }
    
    imageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.bottom.equalToSuperview()
      make.width.height.equalTo(100)
    }
    
    placeholderImageView.snp.makeConstraints { $0.center.equalToSuperview() }
  }
  
  required init?(coder: NSCoder) { nil }
}
