import UIKit

public final class SmallAvatarAndTitleCell: UITableViewCell {
    let separatorView = UIView()
    public let titleLabel = UILabel()
    public let avatarView = AvatarView()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectedBackgroundView = UIView()
        multipleSelectionBackgroundView = UIView()
        backgroundColor = Asset.neutralWhite.color

        titleLabel.textColor = Asset.neutralActive.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)
        separatorView.backgroundColor = Asset.neutralLine.color

        contentView.addSubview(titleLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(separatorView)

        avatarView.snp.makeConstraints {
            $0.width.height.equalTo(36)
            $0.left.equalToSuperview().offset(27)
            $0.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(avatarView)
            $0.left.equalTo(avatarView.snp.right).offset(14)
            $0.right.lessThanOrEqualToSuperview().offset(-10)
        }

        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.left.equalToSuperview().offset(25)
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    public override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        avatarView.prepareForReuse()
    }
}
