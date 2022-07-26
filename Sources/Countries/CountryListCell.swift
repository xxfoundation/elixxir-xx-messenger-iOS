import UIKit
import Shared

final class CountryListCell: UICollectionViewCell {
    private let nameLabel = UILabel()
    private let flagLabel = UILabel()
    private let prefixLabel = UILabel()
    private let separatorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = Asset.neutralWhite.color

        nameLabel.textColor = Asset.neutralDark.color
        prefixLabel.textColor = Asset.neutralWeak.color
        nameLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)
        prefixLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)

        separatorView.backgroundColor = Asset.brandBackground.color
        prefixLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        contentView.addSubview(nameLabel)
        contentView.addSubview(flagLabel)
        contentView.addSubview(prefixLabel)
        contentView.addSubview(separatorView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        flagLabel.text = nil
        prefixLabel.text = nil
    }

    func set(
        flag: String,
        name: String,
        prefix: String
    ) {
        flagLabel.text = flag
        nameLabel.text = name
        prefixLabel.text = prefix
    }

    private func setupConstraints() {
        flagLabel.snp.makeConstraints {
            $0.left.top.equalToSuperview().inset(18)
            $0.bottom.equalToSuperview().offset(-16)
        }

        nameLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(55)
            $0.centerY.equalToSuperview()
            $0.right.lessThanOrEqualTo(prefixLabel.snp.left).offset(-10)
        }

        prefixLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-18)
            $0.centerY.equalToSuperview()
        }

        separatorView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(1)
        }
    }
}
