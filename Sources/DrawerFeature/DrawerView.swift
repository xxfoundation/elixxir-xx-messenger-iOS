import UIKit
import Shared
import AppResources

final class DrawerView: UIView {
  let stackView = UIStackView()

  init() {
    super.init(frame: .zero)

    layer.cornerRadius = 40
    backgroundColor = Asset.neutralWhite.color
    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

    stackView.axis = .vertical
    addSubview(stackView)

    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(40)
      $0.left.equalToSuperview().offset(50)
      $0.right.equalToSuperview().offset(-50)
      $0.bottom.equalToSuperview().offset(-50)
    }
  }

  required init?(coder: NSCoder) { nil }
}
