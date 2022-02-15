import UIKit

public struct CapsuleButtonModel {
    public var title: String
    public var accessibility: String?
    public var style: CapsuleButtonStyle

    public init(
        title: String,
        style: CapsuleButtonStyle,
        accessibility: String? = nil
    ) {
        self.title = title
        self.style = style
        self.accessibility = accessibility
    }
}

public struct CapsuleButtonStyle {
    var fill: UIImage
    var borderWidth: CGFloat
    var borderColor: UIColor?
    var titleColor: UIColor
    var disabledTitleColor: UIColor
}

public extension CapsuleButtonStyle {
    static let white = CapsuleButtonStyle(
        fill: .color(Asset.neutralWhite.color),
        borderWidth: 0,
        borderColor: nil,
        titleColor: Asset.brandPrimary.color,
        disabledTitleColor: Asset.neutralWhite.color
    )

    static let brandColored = CapsuleButtonStyle(
        fill: .color(Asset.brandPrimary.color),
        borderWidth: 0,
        borderColor: nil,
        titleColor: Asset.neutralWhite.color,
        disabledTitleColor: Asset.neutralWhite.color
    )

    static let red = CapsuleButtonStyle(
        fill: .color(Asset.accentDanger.color),
        borderWidth: 0,
        borderColor: nil,
        titleColor: Asset.neutralWhite.color,
        disabledTitleColor: Asset.neutralWhite.color
    )

    static let seeThroughWhite = CapsuleButtonStyle(
        fill: .color(UIColor.clear),
        borderWidth: 2,
        borderColor: Asset.neutralWhite.color,
        titleColor: Asset.neutralWhite.color,
        disabledTitleColor: Asset.neutralWhite.color.withAlphaComponent(0.5)
    )

    static let seeThrough = CapsuleButtonStyle(
        fill: .color(UIColor.clear),
        borderWidth: 2,
        borderColor: Asset.brandPrimary.color,
        titleColor: Asset.brandPrimary.color,
        disabledTitleColor: Asset.brandPrimary.color.withAlphaComponent(0.5)
    )

    static let simplestColored = CapsuleButtonStyle(
        fill: .color(UIColor.clear),
        borderWidth: 0,
        borderColor: nil,
        titleColor: Asset.accentDanger.color,
        disabledTitleColor: Asset.brandDefault.color.withAlphaComponent(0.5)
    )
}

public final class CapsuleButton: UIButton {
    // MARK: Properties

    private let height: CGFloat
    private let minimumWidth: CGFloat

    // MARK: Lifecycle

    public init(
        height: CGFloat = 55.0,
        minimumWidth: CGFloat = 200
    ) {
        self.height = height
        self.minimumWidth = minimumWidth

        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Public

    public func set(
        style: CapsuleButtonStyle,
        title: String,
        accessibility: String? = nil
    ) {
        setTitle(title, for: .normal)
        accessibilityIdentifier = accessibility
        layer.borderWidth = style.borderWidth

        if let color = style.borderColor {
            layer.borderColor = color.cgColor
        }

        setBackgroundImage(style.fill, for: .normal)
        setTitleColor(style.titleColor, for: .normal)
        setTitleColor(style.disabledTitleColor, for: .disabled)
    }

    public func setStyle(_ style: CapsuleButtonStyle) {
        layer.borderWidth = style.borderWidth

        if let color = style.borderColor {
            layer.borderColor = color.cgColor
        }

        setBackgroundImage(style.fill, for: .normal)
        setTitleColor(style.titleColor, for: .normal)
        setTitleColor(style.disabledTitleColor, for: .disabled)
    }

    // MARK: Private

    private func setup() {
        layer.cornerRadius = 55/2
        layer.masksToBounds = true
        titleLabel!.font = Fonts.Mulish.semiBold.font(size: 16.0)
        adjustsImageWhenHighlighted = false

        setBackgroundImage(.color(Asset.neutralDisabled.color), for: .disabled)

        snp.makeConstraints { make in
            make.height.equalTo(height)
            make.width.greaterThanOrEqualTo(minimumWidth)
        }
    }
}
