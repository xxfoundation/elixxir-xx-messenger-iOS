import UIKit

public struct RowButtonStyle {
    var color: UIColor
    var accessory: UIImage?
}

public extension RowButtonStyle {
    static let clean = RowButtonStyle(
        color: Asset.neutralActive.color,
        accessory: Asset.settingsDisclosure.image
    )

    static let delete = RowButtonStyle(
        color: Asset.accentDanger.color,
        accessory: nil
    )
}

public final class RowButton: UIControl {
    public let title = UILabel()
    public let icon = UIImageView()
    public let separator = UIView()
    public let stack = UIStackView()
    public let accessory = UIImageView()

    public init() {
        super.init(frame: .zero)

        icon.contentMode = .center
        title.font = Fonts.Mulish.semiBold.font(size: 14.0)
        separator.backgroundColor = Asset.neutralLine.color
        icon.setContentHuggingPriority(.required, for: .horizontal)

        stack.spacing = 10
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(title.pinning(at: .left(0)))
        stack.addArrangedSubview(
            accessory
                .pinning(at: .top(10))
        )

        addSubview(stack)
        addSubview(separator)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }

        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        subviews.forEach { $0.isUserInteractionEnabled = false }
    }

    required init?(coder: NSCoder) { nil }

    public func set(
        title: String,
        icon: UIImage,
        style: RowButtonStyle = .clean,
        separator: Bool = true
    ) {
        self.icon.image = icon
        self.title.text = title
        self.title.textColor = style.color
        self.accessory.image = style.accessory

        guard separator == true else {
            self.separator.removeFromSuperview()
            return
        }
    }
}
