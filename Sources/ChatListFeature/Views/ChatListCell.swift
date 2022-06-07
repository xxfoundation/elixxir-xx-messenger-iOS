import UIKit
import Shared

final class ChatListCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let unreadView = UIView()
    private let previewLabel = UILabel()
    private let dateLabel = UILabel()
    private let avatarView = AvatarView()
    private var lastDate: Date? {
        didSet { updateTimeAgoLabel() }
    }

    private var timer: Timer?

    deinit { timer?.invalidate() }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        previewLabel.numberOfLines = 2
        dateLabel.textAlignment = .right

        unreadView.layer.cornerRadius = 8
        avatarView.layer.cornerRadius = 21
        avatarView.layer.masksToBounds = true

        dateLabel.textAlignment = .right
        selectedBackgroundView = UIView()
        unreadView.backgroundColor = .clear
        backgroundColor = Asset.neutralWhite.color
        dateLabel.textColor = Asset.neutralWeak.color
        titleLabel.textColor = Asset.neutralActive.color

        dateLabel.font = Fonts.Mulish.semiBold.font(size: 13.0)
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 16.0)


        timer = Timer.scheduledTimer(withTimeInterval: 59, repeats: true) { [weak self] _ in
            self?.updateTimeAgoLabel()
        }

        dateLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        contentView.addSubview(titleLabel)
        contentView.addSubview(unreadView)
        contentView.addSubview(avatarView)
        contentView.addSubview(previewLabel)
        contentView.addSubview(dateLabel)

        avatarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.left.equalToSuperview().offset(24)
            $0.width.height.equalTo(48)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalTo(avatarView.snp.right).offset(16)
            $0.right.lessThanOrEqualTo(dateLabel.snp.left).offset(-10)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel)
            $0.right.equalToSuperview().offset(-25)
        }

        previewLabel.snp.makeConstraints {
            $0.left.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.right.lessThanOrEqualTo(unreadView.snp.left).offset(-3)
            $0.bottom.lessThanOrEqualToSuperview().offset(-10)
        }

        unreadView.snp.makeConstraints {
            $0.right.equalTo(dateLabel)
            $0.centerY.equalTo(previewLabel)
            $0.width.height.equalTo(20)
        }
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        lastDate = nil
        titleLabel.text = nil
        previewLabel.attributedText = nil
        avatarView.prepareForReuse()
    }

    private func updateTimeAgoLabel() {
        if let date = lastDate {
            dateLabel.text = date.asRelativeFromNow()
        }
    }

    func setupContact(
        name: String,
        image: Data?,
        date: Date?,
        hasUnread: Bool,
        preview: String
    ) {
        titleLabel.text = name
        setPreview(string: preview)
        avatarView.setupProfile(title: name, image: image, size: .large)
        unreadView.backgroundColor = hasUnread ? Asset.brandPrimary.color : .clear

        if let date = date {
            lastDate = date
        } else {
            dateLabel.text = nil
        }
    }

    func setupGroup(
        name: String,
        date: Date,
        preview: String?,
        hasUnread: Bool
    ) {
        lastDate = date
        titleLabel.text = name
        setPreview(string: preview)
        avatarView.setupGroup(size: .large)
        unreadView.backgroundColor = hasUnread ? Asset.brandPrimary.color : .clear
    }

    private func setPreview(string: String?) {
        guard let preview = string else {
            previewLabel.attributedText = nil
            return
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1

        previewLabel.attributedText = NSAttributedString(
            string: preview,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: Fonts.Mulish.regular.font(size: 14.0),
                .foregroundColor: Asset.neutralSecondaryAlternative.color
            ])
    }
}
