import UIKit

public struct BottomFeedbackStyle {
    var color: UIColor
    var iconColor: UIColor
    var titleColor: UIColor
    var actionColor: UIColor?
}

public extension BottomFeedbackStyle {
    static let danger = BottomFeedbackStyle(
        color: Asset.accentDanger.color,
        iconColor: Asset.neutralWhite.color,
        titleColor: Asset.neutralWhite.color
    )

    static let chill = BottomFeedbackStyle(
        color: Asset.neutralSecondary.color,
        iconColor: Asset.neutralDisabled.color,
        titleColor: Asset.neutralBody.color
    )
}

public final class BottomFeedbackComponent: UIView {
    // MARK: UI

    public let title = UILabel()
    public let icon = UIImageView()
    public let stack = UIStackView()
    public let button = CapsuleButton(height: 50.0, minimumWidth: 100.0)

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Public

    public func set(
        icon: UIImage,
        title: String,
        style: BottomFeedbackStyle,
        actionTitle: String? = nil,
        actionStyle: CapsuleButtonStyle = .seeThroughWhite
    ) {
        backgroundColor = style.color
        self.icon.tintColor = style.iconColor
        self.title.textColor = style.titleColor

        self.title.text = title
        self.icon.image = icon.withRenderingMode(.alwaysTemplate)

        guard let actionTitle = actionTitle else { return }

        button.setStyle(actionStyle)
        button.setTitle(actionTitle, for: .normal)
        stack.addArrangedSubview(button.pinning(at: .center(0)))
    }

    // MARK: Private

    private func setup() {
        layer.cornerRadius = 15
        icon.contentMode = .center
        title.font = Fonts.Mulish.semiBold.font(size: 14.0)

        stack.spacing = 10
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(title.pinning(at: .left(0)))
        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
}
