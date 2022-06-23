import UIKit
import Shared
import Combine
import Countries

final class RequestCell: UICollectionViewCell {
    let titleLabel = UILabel()
    let leaderLabel = UILabel()
    let emailLabel = UILabel()
    let phoneLabel = UILabel()
    let dateLabel = UILabel()
    let stackView = UIStackView()
    let avatarView = AvatarView()
    let stateButton = RequestCellButton()

    var cancellables = Set<AnyCancellable>()
    var didTapStateButton: (() -> Void)!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Asset.neutralWhite.color

        titleLabel.textColor = Asset.neutralActive.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)

        emailLabel.font = Fonts.Mulish.regular.font(size: 14.0)
        phoneLabel.font = Fonts.Mulish.regular.font(size: 14.0)
        leaderLabel.font = Fonts.Mulish.regular.font(size: 14.0)

        emailLabel.textColor = Asset.neutralSecondaryAlternative.color
        phoneLabel.textColor = Asset.neutralSecondaryAlternative.color
        leaderLabel.textColor = Asset.neutralSecondaryAlternative.color

        dateLabel.font = Fonts.Mulish.regular.font(size: 10.0)
        dateLabel.textColor = Asset.neutralWeak.color

        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(leaderLabel)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(phoneLabel)
        stackView.addArrangedSubview(dateLabel)

        contentView.addSubview(avatarView)
        contentView.addSubview(stateButton)
        contentView.addSubview(stackView)

        avatarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.width.height.equalTo(36)
            $0.left.equalToSuperview().offset(27)
            $0.bottom.lessThanOrEqualToSuperview().offset(-15)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(avatarView).offset(-5)
            $0.left.equalTo(avatarView.snp.right).offset(20)
            $0.right.lessThanOrEqualTo(stateButton.snp.left).offset(-20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-15)
        }

        stateButton.snp.makeConstraints {
            $0.centerY.equalTo(stackView)
            $0.right.equalToSuperview().offset(-24)
        }
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        dateLabel.text = nil
        phoneLabel.text = nil
        emailLabel.text = nil
        leaderLabel.text = nil
        avatarView.prepareForReuse()
        cancellables.removeAll()
    }

    func setupFor(requestSent: RequestSent) {
        cancellables.removeAll()
        guard case .contact(let contact) = requestSent.request else { fatalError("A sent request -must- be of type contact") }

        var phone: String?
        if let contactPhone = contact.phone {
            phone = "\(Country.findFrom(contactPhone).prefix) \(contactPhone.dropLast(2))"
        }

        setupContact(
            title: contact.nickname ?? contact.username!,
            photo: contact.photo,
            phone: phone,
            email: contact.email,
            createdAt: contact.createdAt,
            backgroundColor: Asset.brandPrimary.color
        )

        var buttonTitle: String? = nil
        var buttonImage: UIImage? = nil
        var buttonTitleColor: UIColor? = nil

        if requestSent.isResent {
            buttonTitle = Localized.Requests.Cell.resent
            buttonImage = Asset.requestsResent.image
            buttonTitleColor = Asset.neutralWeak.color
        } else {
            buttonTitle = Localized.Requests.Cell.requested
            buttonImage = Asset.requestsResend.image
            buttonTitleColor = Asset.brandPrimary.color
        }

        setupStateButton(
            image: buttonImage,
            title: buttonTitle,
            color: buttonTitleColor
        )
    }

    func setupFor(requestFailed request: Request) {
        cancellables.removeAll()
        guard case .contact(let contact) = request else { fatalError("A failed request -must- be of type contact") }

        var phone: String?
        if let contactPhone = contact.phone {
            phone = "\(Country.findFrom(contactPhone).prefix) \(contactPhone.dropLast(2))"
        }

        setupContact(
            title: contact.nickname ?? contact.username!,
            photo: contact.photo,
            phone: phone,
            email: contact.email,
            createdAt: contact.createdAt,
            backgroundColor: Asset.brandPrimary.color
        )

        setupStateButton(
            image: Asset.requestsResend.image,
            title: Localized.Requests.Cell.failedRequest,
            color: Asset.brandPrimary.color
        )
    }

    func setupFor(requestReceived: RequestReceived, isHidden: Bool = false) {
        cancellables.removeAll()
        guard let request = requestReceived.request else { return }
        let color = isHidden ? Asset.neutralDisabled.color : Asset.brandPrimary.color

        switch request {
        case .group(let group):
            setupGroup(
                name: group.name,
                createdAt: group.createdAt,
                leader: requestReceived.leader,
                backgroundColor: color
            )

        case .contact(let contact):

            var phone: String?
            if let contactPhone = contact.phone {
                phone = "\(Country.findFrom(contactPhone).prefix) \(contactPhone.dropLast(2))"
            }

            setupContact(
                title: contact.nickname ?? contact.username!,
                photo: contact.photo,
                phone: phone,
                email: contact.email,
                createdAt: contact.createdAt,
                backgroundColor: color
            )

            var buttonTitle: String? = nil
            var buttonImage: UIImage? = nil
            var buttonTitleColor: UIColor? = nil

            switch request.status {
            case .verified, .confirming, .failedToConfirm:
                break // TODO: These statuses don't need UI

            case .verifying:
                buttonTitle = Localized.Requests.Cell.verifying
                buttonTitleColor = Asset.neutralWeak.color

            case .failedToVerify:
                buttonTitle = Localized.Requests.Cell.failedVerification
                buttonImage = Asset.requestsVerificationFailed.image
                buttonTitleColor = Asset.accentDanger.color

            case .requesting, .requested, .failedToRequest:
                fatalError("A receivedRequest can never have the statuses: .requesting, .requested or .failedToRequest")
            }

            setupStateButton(
                image: buttonImage,
                title: buttonTitle,
                color: buttonTitleColor
            )
        }
    }

    private func setupContact(
        title: String,
        photo: Data?,
        phone: String?,
        email: String?,
        createdAt: Date,
        backgroundColor: UIColor
    ) {
        titleLabel.text = title
        phoneLabel.text = phone
        emailLabel.text = email
        dateLabel.text = createdAt.asRelativeFromNow()
        avatarView.setupProfile(title: title, image: photo, size: .small)

        leaderLabel.isHidden = true
        phoneLabel.isHidden = phone == nil
        emailLabel.isHidden = email == nil
        avatarView.backgroundColor = backgroundColor
    }

    private func setupGroup(
        name: String,
        createdAt: Date,
        leader: String?,
        backgroundColor: UIColor
    ) {
        titleLabel.text = name
        stateButton.imageView.image = nil
        stateButton.titleLabel.text = nil
        avatarView.setupGroup(size: .small)
        dateLabel.text = createdAt.asRelativeFromNow()

        leaderLabel.text = leader
        leaderLabel.isHidden = false
        phoneLabel.isHidden = true
        emailLabel.isHidden = true
        avatarView.backgroundColor = backgroundColor
    }

    private func setupStateButton(
        image: UIImage?,
        title: String?,
        color: UIColor?
    ) {
        stateButton.imageView.image = image
        stateButton.titleLabel.text = title
        stateButton.titleLabel.textColor = color

        stateButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] in didTapStateButton() }
            .store(in: &cancellables)
    }
}

