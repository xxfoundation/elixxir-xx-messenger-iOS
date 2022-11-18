import UIKit
import Shared
import AppResources

final class ScanView: UIView {
  private let statusLabel = UILabel()
  private let imageView = UIImageView()
  private let stackView = UIStackView()
  private let animationView = DotAnimation()
  private let overlayView = ScanOverlayView()
  private(set) var actionButton = CapsuleButton()

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

  required init?(coder: NSCoder) { nil }

  func update(with state: ScanStatus) {
    var text: String

    switch state {
    case .reading, .processing:
      imageView.isHidden = true
      actionButton.isHidden = true
      text = Localized.Scan.Status.reading
      overlayView.updateCornerColor(Asset.brandPrimary.color)

    case .success:
      animationView.isHidden = true
      actionButton.isHidden = true
      imageView.isHidden = false
      imageView.image = Asset.sharedSuccess.image
      text = Localized.Scan.Status.success
      overlayView.updateCornerColor(Asset.accentSuccess.color)

    case .failed(let error):
      animationView.isHidden = true
      imageView.image = Asset.scanError.image
      imageView.isHidden = false
      overlayView.updateCornerColor(Asset.accentDanger.color)

      switch error {
      case .requestOpened:
        text = Localized.Scan.Error.requested
        actionButton.setTitle(Localized.Scan.requests, for: .normal)
        actionButton.isHidden = false

      case .alreadyFriends(let name):
        text = Localized.Scan.Error.alreadyFriends(name)
        actionButton.setTitle(Localized.Scan.contact, for: .normal)
        actionButton.isHidden = false

      case .cameraPermission:
        text = Localized.Scan.Error.cameraPermissionNeeded
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
    attString.addAttribute(.font, value: Fonts.Mulish.regular.font(size: 14.0) as Any)

    if text.contains("#") {
      attString.addAttribute(name: .foregroundColor, value: Asset.brandPrimary.color, betweenCharacters: "#")
    }

    statusLabel.attributedText = attString
  }
}
