import UIKit
import Shared

final class VerifyingView: UIView {
    let title = UILabel()
    let subtitle = UILabel()
    let icon = UIImageView()
    let stack = UIStackView()
    let action = CapsuleButton()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        layer.cornerRadius = 15
        backgroundColor = Asset.neutralWhite.color
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        subtitle.numberOfLines = 0
        icon.contentMode = .center
        icon.image = Asset.popupNegative.image
        title.textColor = Asset.neutralDark.color
        subtitle.textColor = Asset.neutralWeak.color

        title.textAlignment = .center
        subtitle.textAlignment = .center
        title.text = "Verifying"
        subtitle.text = "We are working on verifying the request to make sure it is not a spam. Please check again shortly."
        title.font = Fonts.Mulish.semiBold.font(size: 18.0)
        subtitle.font = Fonts.Mulish.semiBold.font(size: 14.0)

        action.setStyle(.brandColored)
        action.setTitle("OK", for: .normal)

        stack.spacing = 20
        stack.axis = .vertical
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(subtitle)
        stack.addArrangedSubview(action)

        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
}
