import UIKit
import Shared
import Combine

final class RequestFailedCell: UITableViewCell {
    // MARK: UI

    let title = UILabel()
    let button = UIButton()
    let subtitle = UILabel()
    let separator = UIView()
    let avatar = AvatarView()

    var cancellables = Set<AnyCancellable>()

    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = nil
        subtitle.text = nil
        avatar.prepareForReuse()
        cancellables.removeAll()
    }

    // MARK: Public

    func setup(
        username: String,
        nickname: String?,
        createdAt: Date,
        photo: Data?
    ) {
        title.text = nickname ?? username
        subtitle.text = createdAt.asRelativeFromNow()

        avatar.set(
            cornerRadius: 8,
            username: nickname ?? username,
            image: photo
        )
    }

    // MARK: Private

    private func setup() {
        selectionStyle = .none
        backgroundColor = Asset.neutralWhite.color

        avatar.layer.cornerRadius = 8

        title.textColor = Asset.accentDanger.color
        title.font = Fonts.Mulish.semiBold.font(size: 14.0)
        separator.backgroundColor = Asset.neutralLine.color

        button.setTitle("Tap to resend", for: .normal)
        button.setTitleColor(Asset.brandPrimary.color, for: .normal)
        button.titleLabel?.font = Fonts.Mulish.semiBold.font(size: 14.0)

        subtitle.font = Fonts.Mulish.regular.font(size: 10.0)
        subtitle.textColor = Asset.neutralWeak.color

        contentView.addSubview(title)
        contentView.addSubview(avatar)
        contentView.addSubview(button)
        contentView.addSubview(subtitle)
        contentView.addSubview(separator)

        setupConstraints()
    }

    private func setupConstraints() {
        avatar.snp.makeConstraints { make in
            make.width.height.equalTo(28)
            make.left.equalToSuperview().offset(25)
            make.centerY.equalTo(title)
        }

        title.snp.makeConstraints { make in
            make.bottom.equalTo(button.snp.centerY)
            make.left.equalTo(avatar.snp.right).offset(10)
            make.right.lessThanOrEqualTo(subtitle.snp.left).offset(-20)
        }

        button.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25)
            make.bottom.equalToSuperview().offset(-8)
        }

        subtitle.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25)
            make.bottom.equalTo(button.snp.top).offset(-3)
        }

        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(title.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
