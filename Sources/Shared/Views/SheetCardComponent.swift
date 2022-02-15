import UIKit

public final class SheetCardComponent: UIView {
    // MARK: UI

    public let stack = UIStackView()

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Public

    public func set(buttons: [CapsuleButton]) {
        buttons.forEach { stack.addArrangedSubview($0) }
    }

    // MARK: Private

    private func setup() {
        layer.cornerRadius = 24
        backgroundColor = Asset.neutralSecondary.color

        stack.spacing = 20
        stack.axis = .vertical
        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
}
