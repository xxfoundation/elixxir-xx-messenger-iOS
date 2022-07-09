import UIKit
import Shared

final class SearchCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let separatorView = UIView()
    private let avatarView = AvatarView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = Asset.neutralWhite.color

        titleLabel.textColor = Asset.neutralActive.color
        subtitleLabel.textColor = Asset.neutralDisabled.color
        separatorView.backgroundColor = Asset.neutralLine.color

        titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)
        subtitleLabel.font = Fonts.Mulish.regular.font(size: 12.0)

        contentView.addSubview(titleLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(separatorView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        avatarView.prepareForReuse()
    }

    func setup(
        title: String,
        subtitle: String,
        avatarTitle: String,
        avatarImage: Data?,
        avatarSize: AvatarView.Size
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        avatarView.setupProfile(
            title: avatarTitle,
            image: avatarImage,
            size: avatarSize
        )
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalTo(avatarView.snp.right).offset(16)
            $0.right.lessThanOrEqualToSuperview().offset(-20)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(3)
            $0.left.equalTo(titleLabel)
            $0.bottom.equalToSuperview().offset(-22)
        }

        avatarView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(28)
            $0.width.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-16)
        }

        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview()
        }
    }
}
