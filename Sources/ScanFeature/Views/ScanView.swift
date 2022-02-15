import UIKit
import Shared

final class ScanView: UIView {
    let overlay = ScanOverlayView()
    let animationView = DotAnimation()
    let iconImageView = UIImageView()
    let statusLabel = UILabel()
    let actionButton = CapsuleButton()
    let stackView = UIStackView()

    init() {
        super.init(frame: .zero)
        iconImageView.contentMode = .center
        actionButton.setStyle(.brandColored)

        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        statusLabel.textColor = Asset.neutralWhite.color
        statusLabel.font = Fonts.Mulish.regular.font(size: 14.0)

        stackView.spacing = 15
        stackView.axis = .vertical
        stackView.addArrangedSubview(animationView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(actionButton)

        animationView.isHidden = false
        iconImageView.isHidden = true
        actionButton.isHidden = true

        addSubview(overlay)
        addSubview(stackView)

        overlay.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(57)
            make.right.equalToSuperview().offset(-57)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-100)
        }
    }

    required init?(coder: NSCoder) { nil }

    func update(with state: ScanStatus) {
        var text: String

        switch state {
        case .reading, .processing:
            iconImageView.isHidden = true
            actionButton.isHidden = true
            text = Localized.Scan.Status.reading
            overlay.updateCornerColor(Asset.brandPrimary.color)

        case .success:
            animationView.isHidden = true
            actionButton.isHidden = true
            iconImageView.isHidden = false
            iconImageView.image = Asset.scanSuccess.image
            text = Localized.Scan.Status.success
            overlay.updateCornerColor(Asset.accentSuccess.color)

        case .failed(let error):
            animationView.isHidden = true
            iconImageView.image = Asset.scanError.image
            iconImageView.isHidden = false
            overlay.updateCornerColor(Asset.accentDanger.color)

            switch error {
            case .requestOpened:
                text = Localized.Scan.Error.requested
                actionButton.setTitle(Localized.Scan.requests, for: .normal)
                actionButton.isHidden = false

            case .alreadyFriends(let name):
                text = Localized.Scan.Error.friends(name)
                actionButton.setTitle(Localized.Scan.contact, for: .normal)
                actionButton.isHidden = false

            case .cameraPermission:
                text = Localized.Scan.Error.denied
                actionButton.setTitle(Localized.Scan.settings, for: .normal)
                actionButton.isHidden = false

            case .unknown(let content):
                text = content
            }
        }

        let attString = NSMutableAttributedString(string: text)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineHeightMultiple = 1.35

        attString.addAttribute(.paragraphStyle, value: paragraph)
        attString.addAttribute(.foregroundColor, value: Asset.neutralWhite.color)
        attString.addAttribute(.font, value: Fonts.Mulish.semiBold.font(size: 18.0) as Any)

        if text.contains("#") {
            attString.addAttribute(name: .foregroundColor, value: Asset.brandPrimary.color, betweenCharacters: "#")
        }

        statusLabel.attributedText = attString
    }
}
