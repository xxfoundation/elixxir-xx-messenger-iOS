import UIKit
import Shared

final class PopupView: UIView {
    // MARK: UI

    let stack = UIStackView()

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)

        stack.axis = .vertical
        layer.cornerRadius = 6
        layer.masksToBounds = true
        backgroundColor = Asset.neutralWhite.color

        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    required init?(coder: NSCoder) { nil }
}
