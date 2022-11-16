import UIKit
import Shared
import Combine

final class RequestsHiddenSectionHeader: UICollectionReusableView {
  let titleLabel = UILabel()
  let separatorView = UIView()
  let switcherView = UISwitch()
  var cancellables = Set<AnyCancellable>()
  
  override func prepareForReuse() {
    super.prepareForReuse()
    cancellables.removeAll()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    titleLabel.text = Localized.Requests.Received.hidden
    titleLabel.textColor = Asset.neutralActive.color
    titleLabel.font = Fonts.Mulish.semiBold.font(size: 16.0)
    separatorView.backgroundColor = Asset.neutralLine.color
    switcherView.onTintColor = Asset.brandPrimary.color
    
    addSubview(titleLabel)
    addSubview(switcherView)
    addSubview(separatorView)
    
    separatorView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.top.equalToSuperview().offset(10)
      $0.left.equalToSuperview().offset(24)
      $0.right.equalToSuperview().offset(-24)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(separatorView.snp.bottom).offset(30)
      $0.left.equalToSuperview().offset(24)
      $0.bottom.equalToSuperview().offset(-20)
    }
    
    switcherView.snp.makeConstraints {
      $0.centerY.equalTo(titleLabel)
      $0.right.equalToSuperview().offset(-24)
    }
  }
  
  required init?(coder: NSCoder) { nil }
}

final class RequestsBlankSectionHeader: UICollectionReusableView {
  private let view = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(view)
    view.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalTo(1)
    }
  }
  
  required init?(coder: NSCoder) { nil }
}
