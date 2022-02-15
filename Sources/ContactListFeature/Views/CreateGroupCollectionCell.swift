import UIKit
import Shared
import Combine

final class CreateGroupCollectionCell: UICollectionViewCell {
    // MARK: UI

    let title = UILabel()
    let remove = UIButton()
    let upperView = UIView()
    let avatar = AvatarView()
    var didTapRemove: (() -> Void)?

    var cancellables = Set<AnyCancellable>()

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = nil
        avatar.prepareForReuse()
        cancellables.removeAll()
    }

    // MARK: Public

    func setup(title: String, image: Data?) {
        self.title.text = title
        self.avatar.set(username: title, image: image)

        cancellables.removeAll()

        remove.publisher(for: .touchUpInside)
            .sink { [unowned self] in didTapRemove?() }
            .store(in: &cancellables)
    }

    // MARK: Private

    private func setup() {
        title.numberOfLines = 2
        title.lineBreakMode = .byWordWrapping
        title.textAlignment = .center
        title.textColor = Asset.neutralDark.color
        title.font = Fonts.Mulish.semiBold.font(size: 14.0)

        remove.layer.cornerRadius = 9
        remove.backgroundColor = Asset.accentDanger.color
        remove.setImage(Asset.contactListAvatarRemove.image, for: .normal)

        upperView.addSubview(avatar)
        contentView.addSubview(title)
        contentView.addSubview(upperView)
        contentView.addSubview(remove)

        upperView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        avatar.snp.makeConstraints { make in
            make.width.equalTo(48)
            make.height.equalTo(48)
            make.top.equalToSuperview().offset(4)
            make.left.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-4)
            make.bottom.equalToSuperview().offset(-4)
        }

        remove.snp.makeConstraints { make in
            make.centerY.equalTo(avatar.snp.top).offset(5)
            make.centerX.equalTo(avatar.snp.right).offset(-5)
            make.width.equalTo(18)
            make.height.equalTo(18)
        }

        title.snp.makeConstraints { make in
            make.top.equalTo(upperView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
