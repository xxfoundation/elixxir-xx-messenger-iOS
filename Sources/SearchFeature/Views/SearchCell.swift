import UIKit
import Shared

final class SearchCell: UITableViewCell {
    // MARK: UI

    let title = UILabel()
    let subtitle = UILabel()
    let separator = UIView()
    let avatar = AvatarView()

    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = nil
    }

    // MARK: Private

    private func setup() {
        selectionStyle = .none
        backgroundColor = Asset.neutralWhite.color

        title.textColor = Asset.neutralActive.color
        subtitle.textColor = Asset.neutralDisabled.color
        separator.backgroundColor = Asset.neutralLine.color

        title.font = Fonts.Mulish.semiBold.font(size: 14.0)
        subtitle.font = Fonts.Mulish.regular.font(size: 12.0)

        contentView.addSubview(title)
        contentView.addSubview(avatar)
        contentView.addSubview(subtitle)
        contentView.addSubview(separator)

        setupConstraints()
    }

    private func setupConstraints() {
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(avatar.snp.right).offset(16)
            make.right.lessThanOrEqualToSuperview().offset(-20)
        }

        subtitle.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(3)
            make.left.equalTo(title)
            make.bottom.equalToSuperview().offset(-22)
        }

        avatar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(28)
            make.width.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-16)
        }

        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview()
        }
    }
}
