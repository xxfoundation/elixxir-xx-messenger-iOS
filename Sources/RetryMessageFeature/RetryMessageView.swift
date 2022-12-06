import UIKit
import Shared
import AppResources

final class RetryMessageView: UIView {
  private let stackView = UIStackView()
  let retryButton = RetryMessageButton()
  let deleteButton = RetryMessageButton()
  let cancelButton = RetryMessageButton()

  init() {
    super.init(frame: .zero)

    layer.cornerRadius = 15
    layer.masksToBounds = true
    backgroundColor = Asset.neutralWhite.color

    retryButton.titleLabel.text = Localized.Chat.RetrySheet.retry
    deleteButton.titleLabel.text = Localized.Chat.RetrySheet.delete
    cancelButton.titleLabel.text = Localized.Chat.RetrySheet.cancel

    retryButton.imageView.image = Asset.lens.image
    deleteButton.imageView.image = Asset.lens.image
    cancelButton.imageView.image = Asset.lens.image

    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.addArrangedSubview(retryButton)
    stackView.addArrangedSubview(deleteButton)
    stackView.addArrangedSubview(cancelButton)

    addSubview(stackView)

    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(10)
      $0.left.right.equalToSuperview()
      $0.bottom.equalTo(safeAreaLayoutGuide)
    }
  }

  required init?(coder: NSCoder) { nil }
}
