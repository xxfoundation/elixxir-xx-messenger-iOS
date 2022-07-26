import UIKit
import Shared

final class DrawerListCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let avatarView = AvatarView()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = Asset.neutralWhite.color

        titleLabel.font = Fonts.Mulish.semiBold.font(size: 16.0)
        subtitleLabel.font = Fonts.Mulish.regular.font(size: 14.0)
        titleLabel.textColor = Asset.neutralActive.color

        stackView.axis = .vertical
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        contentView.addSubview(avatarView)
        contentView.addSubview(stackView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        subtitleLabel.text = nil
        avatarView.prepareForReuse()
    }

    func set(
        image: Data?,
        title: String,
        subtitle: String?,
        subtitleColor: UIColor = Asset.accentSafe.color
    ) {
        titleLabel.text = title
        avatarView.setupProfile(
            title: title,
            image: image,
            size: .medium
        )

        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
            subtitleLabel.textColor = subtitleColor
        } else {
            subtitleLabel.isHidden = true
        }
    }

    private func setupConstraints() {
        avatarView.snp.makeConstraints {
            $0.width.equalTo(36)
            $0.height.equalTo(36)
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10)
        }

        stackView.snp.makeConstraints {
            $0.left.equalTo(avatarView.snp.right).offset(15)
            $0.top.equalTo(avatarView)
            $0.bottom.equalTo(avatarView)
            $0.right.equalToSuperview()
        }
    }
}
