import UIKit
import Shared
import AppResources

final class PhoneCodeField: UIButton {
  public let content = UILabel()

  public init() {
    super.init(frame: .zero)

    content.textColor = Asset.neutralActive.color
    content.font = Fonts.Mulish.semiBold.font(size: 14.0)

    addSubview(content)

    content.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview().offset(11)
      $0.right.equalToSuperview().offset(-11)
      $0.width.equalTo(60)
      $0.bottom.equalToSuperview()
    }
  }

  public required init?(coder: NSCoder) { nil }
}
