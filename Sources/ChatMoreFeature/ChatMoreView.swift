import UIKit
import Shared
import AppResources

final class ChatMoreView: UIView {
  let clearButton = ChatMoreButton()
  let reportButton = ChatMoreButton()
  let detailsButton = ChatMoreButton()
  private let stackView = UIStackView()

  init() {
    super.init(frame: .zero)

    layer.cornerRadius = 40
    layer.masksToBounds = true
    backgroundColor = Asset.neutralWhite.color

    reportButton.tintColor = Asset.accentDanger.color
    detailsButton.tintColor = Asset.neutralDark.color

    clearButton.titleLabel.text = Localized.Chat.SheetMenu.clear
    reportButton.titleLabel.text = Localized.Chat.SheetMenu.report
    detailsButton.titleLabel.text = Localized.Chat.SheetMenu.details

    reportButton.imageView.image = Asset.searchUsername.image
    detailsButton.imageView.image = Asset.searchUsername.image
    clearButton.imageView.image = Asset.chatListDeleteSwipe.image

    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.addArrangedSubview(clearButton)
    stackView.addArrangedSubview(detailsButton)
    stackView.addArrangedSubview(reportButton)
    addSubview(stackView)

    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(25)
      $0.left.right.equalToSuperview()
      $0.bottom.equalTo(safeAreaLayoutGuide)
    }
  }

  required init?(coder: NSCoder) { nil }
}
