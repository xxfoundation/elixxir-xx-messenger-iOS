import UIKit
import Combine
import AppResources

final class AvatarCellButton: UIControl {
  let titleLabel = UILabel()
  let imageView = UIImageView()
  
  init() {
    super.init(frame: .zero)
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .right
    titleLabel.font = Fonts.Mulish.semiBold.font(size: 13.0)
    
    addSubview(imageView)
    addSubview(titleLabel)
    
    imageView.snp.makeConstraints {
      $0.top.greaterThanOrEqualToSuperview()
      $0.left.equalToSuperview()
      $0.centerY.equalToSuperview()
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.greaterThanOrEqualToSuperview()
      $0.left.equalTo(imageView.snp.right).offset(5)
      $0.centerY.equalToSuperview()
      $0.right.equalToSuperview()
      $0.width.equalTo(60)
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  required init?(coder: NSCoder) { nil }
}

public final class AvatarCell: UITableViewCell {
  let h1Label = UILabel()
  let h2Label = UILabel()
  let h3Label = UILabel()
  let h4Label = UILabel()
  let separatorView = UIView()
  let avatarView = AvatarView()
  let stackView = UIStackView()
  let stateButton = AvatarCellButton()
  
  var cancellables = Set<AnyCancellable>()
  public var didTapStateButton: (() -> Void)!
  
  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    selectedBackgroundView = UIView()
    multipleSelectionBackgroundView = UIView()
    backgroundColor = Asset.neutralWhite.color
    
    h1Label.textColor = Asset.neutralActive.color
    h2Label.textColor = Asset.neutralSecondaryAlternative.color
    h3Label.textColor = Asset.neutralSecondaryAlternative.color
    h4Label.textColor = Asset.neutralSecondaryAlternative.color
    
    h1Label.font = Fonts.Mulish.semiBold.font(size: 14.0)
    h2Label.font = Fonts.Mulish.regular.font(size: 14.0)
    h3Label.font = Fonts.Mulish.regular.font(size: 14.0)
    h4Label.font = Fonts.Mulish.regular.font(size: 14.0)
    
    stackView.spacing = 4
    stackView.axis = .vertical
    
    stackView.addArrangedSubview(h1Label)
    stackView.addArrangedSubview(h2Label)
    stackView.addArrangedSubview(h3Label)
    stackView.addArrangedSubview(h4Label)
    
    separatorView.backgroundColor = Asset.neutralLine.color
    
    contentView.addSubview(stackView)
    contentView.addSubview(avatarView)
    contentView.addSubview(stateButton)
    contentView.addSubview(separatorView)
    
    setupConstraints()
  }
  
  required init?(coder: NSCoder) { nil }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    h1Label.text = nil
    h2Label.text = nil
    h3Label.text = nil
    h4Label.text = nil
    
    stateButton.imageView.image = nil
    stateButton.titleLabel.text = nil
    
    avatarView.prepareForReuse()
    cancellables.removeAll()
  }
  
  public func setup(
    title: String,
    image: Data?,
    firstSubtitle: String? = nil,
    secondSubtitle: String? = nil,
    thirdSubtitle: String? = nil,
    showSeparator: Bool = true,
    sent: Bool = false
  ) {
    h1Label.text = title
    
    if let firstSubtitle = firstSubtitle {
      h2Label.isHidden = false
      h2Label.text = firstSubtitle
    } else {
      h2Label.isHidden = true
    }
    
    if let secondSubtitle = secondSubtitle {
      h3Label.isHidden = false
      h3Label.text = secondSubtitle
    } else {
      h3Label.isHidden = true
    }
    
    if let thirdSubtitle = thirdSubtitle {
      h4Label.isHidden = false
      h4Label.text = thirdSubtitle
    } else {
      h4Label.isHidden = true
    }
    
    avatarView.setupProfile(title: title, image: image, size: .medium)
    separatorView.alpha = showSeparator ? 1.0 : 0.0
    
    cancellables.removeAll()
    
    if sent {
      stateButton.imageView.image = Asset.requestsResend.image
      stateButton.titleLabel.text = Localized.Requests.Cell.requested
      stateButton.titleLabel.textColor = Asset.brandPrimary.color
      
      stateButton
        .publisher(for: .touchUpInside)
        .sink { [unowned self] in didTapStateButton() }
        .store(in: &cancellables)
    }
  }
  
  public func updateToResent() {
    stateButton.imageView.image = Asset.requestsResent.image
    stateButton.titleLabel.text = Localized.Requests.Cell.resent
    stateButton.titleLabel.textColor = Asset.neutralWeak.color
    
    cancellables.forEach { $0.cancel() }
    cancellables.removeAll()
  }
  
  private func setupConstraints() {
    avatarView.snp.makeConstraints {
      $0.width.height.equalTo(36)
      $0.left.equalToSuperview().offset(27)
      $0.centerY.equalToSuperview()
    }
    
    stackView.snp.makeConstraints {
      $0.top.equalTo(avatarView)
      $0.left.equalTo(avatarView.snp.right).offset(14)
      $0.right.lessThanOrEqualToSuperview().offset(-10)
      $0.bottom.greaterThanOrEqualTo(avatarView)
      $0.bottom.lessThanOrEqualToSuperview()
    }
    
    separatorView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.top.greaterThanOrEqualTo(stackView.snp.bottom).offset(10)
      $0.left.equalToSuperview().offset(25)
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    
    stateButton.snp.makeConstraints {
      $0.centerY.equalTo(stackView)
      $0.right.equalToSuperview().offset(-24)
    }
  }
}
