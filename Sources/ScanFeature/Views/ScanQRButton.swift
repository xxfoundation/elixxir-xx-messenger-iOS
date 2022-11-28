import UIKit
import Shared
import AppResources

final class ScanQRButton: UIControl {
    private let overlayView = UIView()
    private let copiedLabel = UILabel()
    private(set) var imageView = UIImageView()

    init() {
        super.init(frame: .zero)

        clipsToBounds = true
        overlayView.alpha = 0.0
        layer.cornerRadius = 30
        backgroundColor = Asset.neutralWhite.color
        overlayView.backgroundColor = Asset.brandDefault.color.withAlphaComponent(0.9)

        copiedLabel.text = Localized.Scan.Display.copied
        copiedLabel.textColor = Asset.neutralWhite.color
        copiedLabel.font = Fonts.Mulish.semiBold.font(size: 18.0)

        addSubview(imageView)
        addSubview(overlayView)
        overlayView.addSubview(copiedLabel)

        copiedLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
        }

        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    func setup(code image: CIImage) {
        imageView.image = UIImage(ciImage: image)
    }

    func blinkCopied() {
        UIView.animateKeyframes(withDuration: 1.0, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.1) {
                self.overlayView.alpha = 1.0
            }

            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                self.overlayView.alpha = 0.0
            }
        }
    }
}
