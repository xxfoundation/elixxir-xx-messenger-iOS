import UIKit
import Shared

final class ChatListEmptyView: UIView {
  let titleLabel = UILabel()
  let stackView = UIStackView()
  let contactsButton = CapsuleButton()
  
  init() {
    super.init(frame: .zero)
    
    backgroundColor = Asset.neutralWhite.color
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineHeightMultiple = 1.2
    paragraph.alignment = .center
    
    titleLabel.numberOfLines = 0
    titleLabel.attributedText = NSAttributedString(
      string: Localized.ChatList.emptyTitle,
      attributes: [
        .paragraphStyle: paragraph,
        .foregroundColor: Asset.neutralActive.color,
        .font: Fonts.Mulish.bold.font(size: 24.0)
      ]
    )
    
    contactsButton.setStyle(.brandColored)
    contactsButton.setTitle(Localized.ChatList.action, for: .normal)
    
    stackView.spacing = 24
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(contactsButton)
    
    addSubview(stackView)
    
    stackView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.top.greaterThanOrEqualToSuperview()
      $0.left.equalToSuperview().offset(24)
      $0.right.equalToSuperview().offset(-24)
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }
  
  required init?(coder: NSCoder) { nil }
}
