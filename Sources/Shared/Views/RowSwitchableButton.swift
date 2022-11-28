import UIKit
import AppResources

public enum RowSwitchableButtonState {
  case disclosure
  case switcher(Bool)
}

public final class RowSwitchableButton: UIControl {
  public let title = UILabel()
  public let icon = UIImageView()
  public let separator = UIView()
  
  public let switcher = UISwitch()
  public let disclosureIcon = UIImageView()
  
  public init() {
    super.init(frame: .zero)
    
    icon.contentMode = .center
    title.font = Fonts.Mulish.semiBold.font(size: 14.0)
    separator.backgroundColor = Asset.neutralLine.color
    title.textColor = Asset.neutralActive.color
    disclosureIcon.image = Asset.settingsDisclosure.image
    switcher.onTintColor = Asset.brandLight.color
    
    addSubview(icon)
    addSubview(title)
    addSubview(disclosureIcon)
    addSubview(switcher)
    addSubview(separator)
    
    icon.snp.makeConstraints {
      $0.top.equalToSuperview().offset(20)
      $0.left.equalToSuperview().offset(36)
      $0.bottom.equalToSuperview().offset(-20)
    }
    
    title.snp.makeConstraints {
      $0.left.equalTo(icon.snp.right).offset(25)
      $0.centerY.equalTo(icon)
    }
    
    disclosureIcon.snp.makeConstraints {
      $0.centerY.equalTo(icon)
      $0.right.equalToSuperview().offset(-48)
    }
    
    switcher.snp.makeConstraints {
      $0.right.equalToSuperview().offset(-25)
      $0.centerY.equalTo(icon)
    }
    
    separator.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.left.equalToSuperview().offset(24)
      $0.right.equalToSuperview().offset(-24)
      $0.bottom.equalToSuperview()
    }
  }
  
  public required init?(coder: NSCoder) { nil }
  
  public func setup(
    title: String,
    icon: UIImage,
    state: RowSwitchableButtonState = .disclosure,
    separator: Bool = true
  ) {
    self.icon.image = icon
    self.title.text = title
    
    switch state {
    case .disclosure:
      switcher.isHidden = true
      disclosureIcon.isHidden = false
      
    case .switcher(let bool):
      switcher.isOn = bool
      switcher.isHidden = false
      disclosureIcon.isHidden = true
    }
    
    guard separator == true else {
      self.separator.removeFromSuperview()
      return
    }
  }
}
