import UIKit
import Shared
import Combine

final class CreateGroupHeroCollectionCell: UICollectionViewCell {
    private let upperView = UIView()
    private let titleLabel = UILabel()
    private let avatarView = AvatarView()
    private let removeButton = UIButton()
    private var didTapAction: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center
        titleLabel.textColor = Asset.neutralDark.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)

        removeButton.layer.cornerRadius = 9
        removeButton.backgroundColor = Asset.accentDanger.color
        removeButton.setImage(Asset.contactListAvatarRemove.image, for: .normal)

        upperView.addSubview(avatarView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(upperView)
        contentView.addSubview(removeButton)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()

        didTapAction = nil
        titleLabel.text = nil
        avatarView.prepareForReuse()
        cancellables.removeAll()
    }

    func setup(
        title: String,
        image: Data?,
        action: @escaping () -> Void
    ) {
        avatarView.setupProfile(
            title: title,
            image: image,
            size: .large
        )

        titleLabel.text = title
        didTapAction = action

        cancellables.removeAll()

        removeButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in didTapAction?() }
            .store(in: &cancellables)
    }

    private func setupConstraints() {
        upperView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }

        avatarView.snp.makeConstraints {
            $0.width.equalTo(48)
            $0.height.equalTo(48)
            $0.top.equalToSuperview().offset(4)
            $0.left.equalToSuperview().offset(4)
            $0.right.equalToSuperview().offset(-4)
            $0.bottom.equalToSuperview().offset(-4)
        }

        removeButton.snp.makeConstraints {
            $0.centerY.equalTo(avatarView.snp.top).offset(5)
            $0.centerX.equalTo(avatarView.snp.right).offset(-5)
            $0.width.equalTo(18)
            $0.height.equalTo(18)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(upperView.snp.bottom)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
