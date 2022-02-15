import UIKit
import Shared

final class SegmentedControlButton: UIControl {
    let title = UILabel()
    let icon = UIImageView()
    let stack = UIStackView()

    init() {
        super.init(frame: .zero)

        title.textColor = Asset.neutralWhite.color
        title.font = Fonts.Mulish.bold.font(size: 15.0)

        addSubview(icon)
        addSubview(title)

        stack.spacing = 6
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(title)
        stack.isUserInteractionEnabled = false

        addSubview(stack)

        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) { nil }
}
