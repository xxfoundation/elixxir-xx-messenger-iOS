import UIKit
import Shared
import SnapKit

final class SearchSegmentedControl: UIView {
    private let trackView = UIView()
    private let stackView = UIStackView()
    private var leftConstraint: Constraint?
    private let trackIndicatorView = UIView()
    private(set) var usernameButton = SearchSegmentedButton()
    private(set) var emailButton = SearchSegmentedButton()
    private(set) var phoneButton = SearchSegmentedButton()
    private(set) var qrCodeButton = SearchSegmentedButton()

    init() {
        super.init(frame: .zero)
        trackView.backgroundColor = Asset.neutralLine.color
        trackIndicatorView.backgroundColor = Asset.brandPrimary.color

        qrCodeButton.titleLabel.text = Localized.Ud.Tab.qr
        emailButton.titleLabel.text = Localized.Ud.Tab.email
        phoneButton.titleLabel.text = Localized.Ud.Tab.phone
        usernameButton.titleLabel.text = Localized.Ud.Tab.username

        usernameButton.titleLabel.textColor = Asset.brandPrimary.color
        emailButton.titleLabel.textColor = Asset.neutralDisabled.color
        phoneButton.titleLabel.textColor = Asset.neutralDisabled.color
        qrCodeButton.titleLabel.textColor = Asset.neutralDisabled.color

        usernameButton.imageView.tintColor = Asset.brandPrimary.color
        emailButton.imageView.tintColor = Asset.neutralDisabled.color
        phoneButton.imageView.tintColor = Asset.neutralDisabled.color
        qrCodeButton.imageView.tintColor = Asset.neutralDisabled.color

        qrCodeButton.imageView.image = Asset.searchTabQr.image
        emailButton.imageView.image = Asset.searchTabEmail.image
        phoneButton.imageView.image = Asset.searchTabPhone.image
        usernameButton.imageView.image = Asset.searchTabUsername.image

        stackView.addArrangedSubview(usernameButton)
        stackView.addArrangedSubview(emailButton)
        stackView.addArrangedSubview(phoneButton)
        stackView.addArrangedSubview(qrCodeButton)
        stackView.distribution = .fillEqually
        stackView.backgroundColor = Asset.neutralWhite.color

        addSubview(stackView)
        addSubview(trackView)
        trackView.addSubview(trackIndicatorView)

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        trackView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
        }

        trackIndicatorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            leftConstraint = $0.left.equalToSuperview().constraint
            $0.width.equalToSuperview().dividedBy(4)
            $0.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    func updateSwipePercentage(_ percentageScrolled: CGFloat) {
        let amountOfTabs = 4.0
        let tabWidth = bounds.width / amountOfTabs
        let leftOffset = percentageScrolled * tabWidth

        leftConstraint?.update(offset: leftOffset)

        let usernamePercentage = percentageScrolled > 1 ? 1 : percentageScrolled
        let phonePercentage = percentageScrolled <= 1 ? 0 : percentageScrolled - 1
        let emailPercentage = percentageScrolled > 1 ? 1 - (percentageScrolled-1) : percentageScrolled
        let qrPercentage = percentageScrolled > 1 ? 1 - (percentageScrolled-1) : percentageScrolled

        let usernameColor = UIColor.fade(
            from: Asset.brandPrimary.color,
            to: Asset.neutralDisabled.color,
            pcent: usernamePercentage
        )

        let emailColor = UIColor.fade(
            from: Asset.neutralDisabled.color,
            to: Asset.brandPrimary.color,
            pcent: emailPercentage
        )

        let phoneColor = UIColor.fade(
            from: Asset.neutralDisabled.color,
            to: Asset.brandPrimary.color,
            pcent: phonePercentage
        )

        let qrColor = UIColor.fade(
            from: Asset.brandPrimary.color,
            to: Asset.neutralDisabled.color,
            pcent: qrPercentage
        )

        usernameButton.imageView.tintColor = usernameColor
        usernameButton.titleLabel.textColor = usernameColor

        emailButton.imageView.tintColor = emailColor
        emailButton.titleLabel.textColor = emailColor

        phoneButton.imageView.tintColor = phoneColor
        phoneButton.titleLabel.textColor = phoneColor

        qrCodeButton.imageView.tintColor = qrColor
        qrCodeButton.titleLabel.textColor = qrColor
    }
}
