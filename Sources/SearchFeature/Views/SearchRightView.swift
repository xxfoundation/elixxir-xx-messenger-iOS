import UIKit
import Shared

final class SearchRightView: UIView {
    let statusLabel = UILabel()
    let imageView = UIImageView()
    let stackView = UIStackView()
    let overlayView = OverlayView()
    let animationView = DotAnimation()
    let actionButton = CapsuleButton()

    init() {
        super.init(frame: .zero)
        imageView.contentMode = .center
        actionButton.setStyle(.brandColored)

        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        statusLabel.textColor = Asset.neutralWhite.color
        statusLabel.font = Fonts.Mulish.regular.font(size: 14.0)

        stackView.spacing = 15
        stackView.axis = .vertical
        stackView.addArrangedSubview(animationView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(actionButton)

        imageView.isHidden = true
        actionButton.isHidden = true
        animationView.isHidden = false

        addSubview(overlayView)
        addSubview(stackView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    func update(status: ScanningStatus) {
        setupTitle(for: status)
        setupImageView(for: status)
        setupActionButton(for: status)
        setupCornerColors(for: status)
        setupAnimationView(for: status)
    }

    private func setupTitle(for status: ScanningStatus) {
        let title: String

        switch status {
        case .success:
            title = Localized.Scan.Status.success
        case .reading:
            title = Localized.Scan.Status.reading
        case .processing:
            title = Localized.Scan.Status.processing

        case .failed(let scanningError):
            switch scanningError {
            case .unknown(let content):
                title = content

            case .requestOpened:
                title = Localized.Scan.Error.requested
            case .alreadyFriends(let name):
                title = Localized.Scan.Error.alreadyFriends(name)
            case .cameraPermission:
                title = Localized.Scan.Error.cameraPermissionNeeded
            }
        }

        let attString = NSMutableAttributedString(string: title)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineHeightMultiple = 1.35

        attString.addAttribute(.paragraphStyle, value: paragraph)
        attString.addAttribute(.foregroundColor, value: Asset.neutralWhite.color)
        attString.addAttribute(.font, value: Fonts.Mulish.regular.font(size: 14.0) as Any)

        if title.contains("#") {
            attString.addAttribute(name: .foregroundColor, value: Asset.brandPrimary.color, betweenCharacters: "#")
        }

        statusLabel.attributedText = attString
    }

    private func setupImageView(for status: ScanningStatus) {
        let image: UIImage?

        switch status {
        case .reading, .processing:
            image = nil
        case .success:
            image = Asset.sharedSuccess.image
        case .failed(_):
            image = Asset.scanError.image
        }

        imageView.image = image
        imageView.isHidden = image == nil
    }

    private func setupActionButton(for status: ScanningStatus) {
        let buttonTitle: String?

        switch status {
        case .failed(.requestOpened):
            buttonTitle = Localized.Scan.requests
        case .failed(.alreadyFriends(_)):
            buttonTitle = Localized.Scan.contact
        case .failed(.cameraPermission):
            buttonTitle = Localized.Scan.settings
        case .reading, .processing, .success, .failed(.unknown(_)):
            buttonTitle = nil
        }

        actionButton.setTitle(buttonTitle, for: .normal)
        actionButton.isHidden = buttonTitle == nil
    }

    private func setupCornerColors(for status: ScanningStatus) {
        let color: UIColor

        switch status {
        case .reading, .processing:
            color = Asset.brandPrimary.color
        case .success:
            color = Asset.accentSuccess.color
        case .failed(_):
            color = Asset.accentDanger.color
        }

        overlayView.updateCornerColor(color)
    }

    private func setupAnimationView(for status: ScanningStatus) {
        switch status {
        case .reading, .processing:
            animationView.isHidden = false
        case .success, .failed(_):
            animationView.isHidden = true
        }
    }

    private func setupConstraints() {
        overlayView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(57)
            $0.right.equalToSuperview().offset(-57)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-100)
        }
    }
}
