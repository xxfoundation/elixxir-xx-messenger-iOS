import UIKit
import AppResources

public final class DetailRowButton: UIControl {
  let titleLabel = UILabel()
  let valueLabel = UILabel()
  let rowIndicator = UIImageView()
  
  public init() {
    super.init(frame: .zero)
    
    rowIndicator.contentMode = .center
    rowIndicator.image = Asset.settingsDisclosure.image
    
    titleLabel.font = Fonts.Mulish.bold.font(size: 12.0)
    valueLabel.font = Fonts.Mulish.regular.font(size: 16.0)
    
    titleLabel.textColor = Asset.neutralWeak.color
    valueLabel.textColor = Asset.neutralActive.color
    
    addSubview(titleLabel)
    addSubview(valueLabel)
    addSubview(rowIndicator)
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview()
    }
    valueLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(4)
      $0.left.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    rowIndicator.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.right.equalToSuperview()
    }
  }
  
  required init?(coder: NSCoder) { nil }
  
  public func setup(title: String, value: String, hasArrow: Bool = true) {
    titleLabel.text = title
    valueLabel.text = value
    rowIndicator.isHidden = !hasArrow
  }
}
