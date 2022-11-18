import UIKit
import Shared
import Combine
import AppResources

final class ScanDisplayView: UIView {
  var actionPublisher: AnyPublisher<ScanDisplayShareView.Action, Never> {
    shareSheetView.actionPublisher.eraseToAnyPublisher()
  }

  private let copyLabel = UILabel()
  private let codeButton = ScanQRButton()
  private let copyImageView = UIImageView()
  private let copyContainerButton = UIControl()
  private var cancellables = Set<AnyCancellable>()
  private let shareSheetView = ScanDisplayShareView()

  init() {
    super.init(frame: .zero)
    backgroundColor = Asset.neutralDark.color

    copyImageView.image = Asset.scanCopy.image
    copyLabel.text = Localized.Scan.Display.copy
    copyLabel.textColor = Asset.neutralDisabled.color
    copyLabel.font = Fonts.Mulish.semiBold.font(size: 13.0)

    codeButton.publisher(for: .touchUpInside)
      .merge(with: copyContainerButton.publisher(for: .touchUpInside))
      .sink { [unowned self] in
        UIGraphicsBeginImageContext(codeButton.frame.size)
        codeButton.layer.render(in: UIGraphicsGetCurrentContext()!)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        UIImageWriteToSavedPhotosAlbum(output!, nil, nil, nil)
        codeButton.blinkCopied()
      }.store(in: &cancellables)

    addSubview(codeButton)
    addSubview(copyContainerButton)
    copyContainerButton.addSubview(copyLabel)
    copyContainerButton.addSubview(copyImageView)

    addSubview(shareSheetView)

    codeButton.snp.makeConstraints {
      $0.centerX.equalTo(safeAreaLayoutGuide)
      $0.centerY.equalTo(safeAreaLayoutGuide).multipliedBy(0.6)
      $0.width.equalTo(safeAreaLayoutGuide).multipliedBy(0.6)
      $0.height.equalTo(codeButton.snp.width)
    }

    copyContainerButton.snp.makeConstraints {
      $0.top.equalTo(codeButton.snp.bottom).offset(33)
      $0.centerX.equalTo(codeButton)
    }

    copyImageView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalToSuperview()
      $0.bottom.equalToSuperview()
    }

    copyLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.equalTo(copyImageView.snp.right).offset(5)
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
    }

    shareSheetView.snp.makeConstraints {
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }

  func setup(code image: CIImage) {
    codeButton.setup(code: image)
  }

  func setupAttributes(
    email: String?,
    phone: String?,
    emailSharing: Bool,
    phoneSharing: Bool
  ) {
    if let email = email {
      shareSheetView.setup(email: .init(content: email, isVisible: emailSharing))
    } else {
      shareSheetView.setup(email: nil)
    }

    if let phone = phone {
      shareSheetView.setup(phone: .init(content: phone, isVisible: phoneSharing))
    } else {
      shareSheetView.setup(phone: nil)
    }
  }
}
