import UIKit
import Shared
import AppResources

final class ChatSearchEmptyView: UIView {
  let titleLabel = UILabel()
  let stackView = UIStackView()
  let descriptionLabel = UILabel()
  let searchButton = CapsuleButton()

  init() {
    super.init(frame: .zero)
    backgroundColor = Asset.neutralWhite.color

    titleLabel.textColor = Asset.brandPrimary.color
    titleLabel.font = Fonts.Mulish.bold.font(size: 24.0)

    let paragraph = NSMutableParagraphStyle()
    paragraph.lineHeightMultiple = 1.2

    descriptionLabel.numberOfLines = 0
    descriptionLabel.attributedText = NSAttributedString(
      string: "was not found in your connections or in a chat. Click below to search for them as a new connection.",
      attributes: [
        .paragraphStyle: paragraph,
        .foregroundColor: Asset.neutralActive.color,
        .font: Fonts.Mulish.regular.font(size: 16.0)
      ]
    )

    searchButton.setStyle(.brandColored)
    searchButton.setTitle("Search for a connection", for: .normal)

    stackView.axis = .vertical
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(descriptionLabel)
    stackView.addArrangedSubview(searchButton)

    stackView.setCustomSpacing(10, after: titleLabel)
    stackView.setCustomSpacing(30, after: descriptionLabel)

    addSubview(stackView)

    stackView.snp.makeConstraints {
      $0.centerY.equalToSuperview().multipliedBy(0.5)
      $0.top.greaterThanOrEqualToSuperview()
      $0.left.equalToSuperview().offset(24)
      $0.right.equalToSuperview().offset(-24)
      $0.bottom.lessThanOrEqualToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }

  func updateSearched(content: String) {
    titleLabel.text = content
  }
}
