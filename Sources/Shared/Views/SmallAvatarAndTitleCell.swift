import UIKit

public final class SmallAvatarAndTitleCell: UITableViewCell {
    // MARK: UI

    public let title = UILabel()
    public let avatar = AvatarView()
    private let separator = UIView()

    // MARK: Lifecycle

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    public override func prepareForReuse() {
        super.prepareForReuse()
        title.text = nil
        avatar.prepareForReuse()
    }

    // MARK: Private

    private func setup() {
        selectedBackgroundView = UIView()
        multipleSelectionBackgroundView = UIView()
        backgroundColor = Asset.neutralWhite.color

        title.textColor = Asset.neutralActive.color
        title.font = Fonts.Mulish.semiBold.font(size: 14.0)
        separator.backgroundColor = Asset.neutralLine.color

        contentView.addSubview(title)
        contentView.addSubview(avatar)
        contentView.addSubview(separator)

        setupConstraints()
    }

    private func setupConstraints() {
        avatar.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.left.equalToSuperview().offset(25)
            make.centerY.equalToSuperview()
        }

        title.snp.makeConstraints { make in
            make.centerY.equalTo(avatar)
            make.left.equalTo(avatar.snp.right).offset(14)
            make.right.lessThanOrEqualToSuperview().offset(-10)
        }

        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
