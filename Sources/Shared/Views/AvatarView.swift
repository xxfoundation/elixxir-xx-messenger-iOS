import UIKit

public final class AvatarView: UIView {
    // MARK: UI

    let initials = UILabel()
    let image = UIImageView()

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Public

    public func set(
        cornerRadius: CGFloat = 16,
        fontSize: CGFloat = 14.0,
        username: String,
        image: Data?
    ) {
        layer.cornerRadius = cornerRadius
        self.initials.text = "\(username.prefix(2))".uppercased()
        self.image.image = image != nil ? UIImage(data: image!) : nil
        self.initials.font = Fonts.Mulish.semiBold.font(size: fontSize)
        self.backgroundColor = username.getColor()
    }

    public func prepareForReuse() {
        image.image = nil
        initials.text = nil
    }

    // MARK: Private

    private func setup() {
        layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        backgroundColor = Asset.accentSafe.color

        initials.textColor = Asset.neutralWhite.color
        initials.font = Fonts.Mulish.semiBold.font(size: 14.0)

        addSubview(initials)
        addSubview(image)

        initials.snp.makeConstraints { $0.center.equalToSuperview() }
        image.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

private extension String {
    func getColor() -> UIColor {
        switch first?.uppercased() {
        case "A", "G", "M", "S", "W":
            return Asset.brandPrimary.color
        case "B", "H", "N", "T", "Y":
            return Asset.brandDefault.color
        case "C", "I", "O", "U":
            return Asset.accentDanger.color
        case "D", "J", "P", "V":
            return Asset.accentSafe.color
        case "E", "K", "Q", "X":
            return Asset.accentSuccess.color
        case "F", "L", "R", "Z":
            return Asset.accentWarning.color
        default:
            return Asset.neutralActive.color
        }
    }
}
