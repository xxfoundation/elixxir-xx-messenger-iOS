import UIKit
import Shared

final class ChatInputReply: UIView {

    let nameLabel = UILabel()
    let titleLabel = UILabel()
    let abortButton = UIButton()
    let messageLabel = UILabel()

    init() {
        super.init(frame: .zero)
        setup()
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

    private func setup() {
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

        setupConstraints()
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(19)
            make.right.lessThanOrEqualToSuperview()
            make.height.equalTo(15)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(11)
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualToSuperview().offset(-30)
            make.height.equalTo(10)
        }

        messageLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(28)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-41)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(30)
        }

        abortButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
    }
}
