import UIKit
import Shared
import Combine

final class RequestReceivedCell: UITableViewCell {
    // MARK: UI

    let title = UILabel()
    let subtitle = UILabel()
    let separator = UIView()
    let avatar = AvatarView()
    let accept = UIButton()
    let reject = UIButton()
    let stack = UIStackView()
    let verification = UIButton()

    // MARK: Properties

    var didTapAccept: (() -> Void)?
    var didTapReject: (() -> Void)?
    var didTapVerification: (() -> Void)?
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

    func setup(name: String, createdAt: Date, photo: Data?, actionsHidden: Bool, verificationFailed: Bool) {
        cancellables.removeAll()

        title.text = name
        subtitle.text = createdAt.asRelativeFromNow()
        avatar.set(cornerRadius: 8, username: name, image: photo)

        accept.publisher(for: .touchUpInside)
            .sink { [unowned self] in didTapAccept?() }
            .store(in: &cancellables)

        reject.publisher(for: .touchUpInside)
            .sink { [unowned self] in didTapReject?() }
            .store(in: &cancellables)

        verification.publisher(for: .touchUpInside)
            .sink { [unowned self] in didTapVerification?() }
            .store(in: &cancellables)

        stack.isHidden = actionsHidden
        verification.isHidden = !actionsHidden

        if verificationFailed {
            verification.setAttributedTitle(.init(
                string: "Failed to verify",
                attributes: [
                    .underlineColor: Asset.accentDanger.color,
                    .foregroundColor: Asset.accentDanger.color,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]), for: .normal
            )
        } else {
            verification.setAttributedTitle(.init(
                string: "Verifying...",
                attributes: [
                    .underlineColor: Asset.neutralDark.color,
                    .foregroundColor: Asset.neutralDark.color,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]), for: .normal
            )
        }
    }

    // MARK: Private

    private func setup() {
        selectionStyle = .none
        backgroundColor = Asset.neutralWhite.color

        accept.setImage(Asset.requestsAccept.image, for: .normal)
        reject.setImage(Asset.requestsReject.image, for: .normal)

        title.textColor = Asset.neutralActive.color
        title.font = Fonts.Mulish.semiBold.font(size: 14.0)
        separator.backgroundColor = Asset.neutralLine.color

        subtitle.font = Fonts.Mulish.regular.font(size: 10.0)
        subtitle.textColor = Asset.neutralWeak.color

        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.addArrangedSubview(accept)
        stack.addArrangedSubview(reject)

        contentView.addSubview(title)
        contentView.addSubview(stack)
        contentView.addSubview(avatar)
        contentView.addSubview(subtitle)
        contentView.addSubview(separator)
        contentView.addSubview(verification)

        setupConstraints()
    }

    private func setupConstraints() {
        avatar.snp.makeConstraints { make in
            make.width.height.equalTo(28)
            make.left.equalToSuperview().offset(25)
            make.centerY.equalToSuperview()
        }

        title.snp.makeConstraints { make in
            make.top.equalTo(avatar).offset(-5)
            make.left.equalTo(avatar.snp.right).offset(10)
            make.right.lessThanOrEqualTo(stack.snp.left).offset(-20)
        }

        subtitle.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(5)
            make.left.equalTo(title)
        }

        stack.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
        }

        separator.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        verification.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
        }
    }
}
