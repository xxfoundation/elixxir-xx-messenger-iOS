import UIKit
import Shared

final class SecureInputButton: UIView {
    private(set) var button = UIButton()
    private let color = Asset.neutralSecondaryAlternative.color
    private lazy var openedImage = Asset.eyeOpen.image.withTintColor(color)
    private lazy var closedImage = Asset.eyeClosed.image.withTintColor(color)

    init() {
        super.init(frame: .zero)

        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setImage(Asset.eyeClosed.image.withTintColor(color), for: .normal)

        addSubview(button)

        button.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(10)
            $0.right.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    func setSecure(_ bool: Bool) {
        button.setImage(bool ? closedImage : openedImage, for: .normal)
    }
}
