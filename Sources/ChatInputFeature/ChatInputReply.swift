import UIKit
import Shared
import AppResources

final class ChatInputReply: UIView {
  let nameLabel = UILabel()
  let titleLabel = UILabel()
  let abortButton = UIButton()
  let messageLabel = UILabel()

  init() {
    super.init(frame: .zero)

    titleLabel.text = "Replying to"
    messageLabel.numberOfLines = 2
    abortButton.setImage(Asset.replyAbort.image, for: .normal)

    nameLabel.font = Fonts.Mulish.bold.font(size: 11.0)
    titleLabel.font = Fonts.Mulish.regular.font(size: 12.0)
    messageLabel.font = Fonts.Mulish.regular.font(size: 11.0)

    nameLabel.textColor = Asset.neutralBody.color
    titleLabel.textColor = Asset.neutralBody.color
    messageLabel.textColor = Asset.neutralBody.color

    addSubview(nameLabel)
    addSubview(titleLabel)
    addSubview(abortButton)
    addSubview(messageLabel)

    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(10)
      $0.left.equalToSuperview().offset(19)
      $0.right.lessThanOrEqualToSuperview()
      $0.height.equalTo(15)
    }

    nameLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(11)
      $0.left.equalTo(titleLabel)
      $0.right.lessThanOrEqualToSuperview().offset(-30)
      $0.height.equalTo(10)
    }

    messageLabel.snp.makeConstraints {
      $0.left.equalToSuperview().offset(28)
      $0.top.equalTo(nameLabel.snp.bottom).offset(4)
      $0.right.equalToSuperview().offset(-41)
      $0.bottom.equalToSuperview().offset(-10)
      $0.height.equalTo(30)
    }

    abortButton.snp.makeConstraints {
      $0.top.equalToSuperview().offset(12)
      $0.right.equalToSuperview().offset(-12)
    }
  }

  required init?(coder: NSCoder) { nil }

  func setup(message: String?, sender: String?) {
    guard let message = message else {
      isHidden = true
      return
    }

    isHidden = false
    messageLabel.text = message
    nameLabel.text = sender ?? "You"
  }
}
