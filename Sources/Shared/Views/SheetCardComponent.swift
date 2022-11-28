import UIKit
import AppResources

public final class SheetCardComponent: UIView {
  public let stackView = UIStackView()
  
  public init() {
    super.init(frame: .zero)
    
    layer.cornerRadius = 24
    backgroundColor = Asset.neutralSecondary.color
    
    stackView.spacing = 20
    stackView.axis = .vertical
    addSubview(stackView)
    
    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(24)
      $0.left.equalToSuperview().offset(24)
      $0.right.equalToSuperview().offset(-24)
      $0.bottom.equalToSuperview().offset(-24)
    }
  }
  
  required init?(coder: NSCoder) { nil }
  
  public func set(buttons: [CapsuleButton]) {
    buttons.forEach { stackView.addArrangedSubview($0) }
  }
}
