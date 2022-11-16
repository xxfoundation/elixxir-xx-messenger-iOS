import UIKit
import AppResources

public extension UIButton {
  static func back(color: UIColor = Asset.neutralActive.color) -> UIButton {
    let back = UIButton()
    back.setImage(Asset.navigationBarBack.image, for: .normal)
    back.tintColor = color
    back.imageView?.contentMode = .center
    back.snp.makeConstraints { $0.width.equalTo(50) }
    return back
  }
}
