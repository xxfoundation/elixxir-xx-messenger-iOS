import UIKit
import Shared

final class LockerView: UIView {
    let icon = UIImageView()
    let animation = CABasicAnimation()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    public func stop() {
        icon.layer.removeAllAnimations()
        icon.layer.opacity = 1.0
    }

    public func fail() {
        icon.layer.removeAllAnimations()
        icon.layer.opacity = 0.3
    }

    public func animate() {
        icon.layer.removeAllAnimations()
        icon.layer.add(animation, forKey: "opacity")
    }

    private func setup() {
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 0.5
        animation.autoreverses = true
        animation.repeatCount = .infinity

        icon.contentMode = .center
        icon.image = Asset.chatLocker.image

        addSubview(icon)

        icon.snp.makeConstraints { $0.edges.equalToSuperview().inset(5) }
    }
}
