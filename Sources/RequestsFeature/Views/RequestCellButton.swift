import UIKit
import Shared

final class RequestCellButton: UIControl {
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
