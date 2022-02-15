import UIKit
import Shared

final class CountryListCell: UITableViewCell {
    let name = UILabel()
    let flag = UILabel()
    let prefix = UILabel()
    let separator = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        setup()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()

        name.text = nil
        flag.text = nil
        prefix.text = nil
    }

    private func setup() {
        backgroundColor = Asset.neutralWhite.color

        name.textColor = Asset.neutralDark.color
        prefix.textColor = Asset.neutralWeak.color
        name.font = Fonts.Mulish.semiBold.font(size: 14.0)
        prefix.font = Fonts.Mulish.semiBold.font(size: 14.0)

        separator.backgroundColor = Asset.brandBackground.color
        prefix.setContentCompressionResistancePriority(.required, for: .horizontal)

        contentView.addSubview(name)
        contentView.addSubview(flag)
        contentView.addSubview(prefix)
        contentView.addSubview(separator)

        flag.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-16)
        }

        name.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(55)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(prefix.snp.left).offset(-10)
        }

        prefix.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
        }

        separator.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(1)
        }
    }
}
