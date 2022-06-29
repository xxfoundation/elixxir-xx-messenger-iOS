import UIKit

public final class AvatarView: UIView {
    public enum Size {
        case small
        case medium
        case large
    }

    let imageView = UIImageView()
    let monogramLabel = UILabel()
    let iconImageView = UIImageView()

    public init() {
        super.init(frame: .zero)

        layer.masksToBounds = true
        backgroundColor = Asset.brandPrimary.color

        iconImageView.contentMode = .center
        imageView.contentMode = .scaleAspectFill
        monogramLabel.textColor = Asset.neutralWhite.color

        addSubview(monogramLabel)
        addSubview(iconImageView)
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        monogramLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    public func prepareForReuse() {
        imageView.image = nil
        monogramLabel.text = nil
        iconImageView.image = nil
    }

    public func setupProfile(title: String, image: Data?, size: AvatarView.Size) {
        iconImageView.image = nil
        monogramLabel.text = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .prefix(2)
            .uppercased()

        monogramLabel.text = "\(title.prefix(2))".uppercased()

        // TODO: What are the font sizes and corner radius for small/medium avatars?

        switch size {
        case .small:
            layer.cornerRadius = 13.0
            monogramLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)
        case .medium:
            layer.cornerRadius = 13.0
            monogramLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)
        case .large:
            layer.cornerRadius = 18.0
            monogramLabel.font = Fonts.Mulish.semiBold.font(size: 16.0)
        }

        guard let image = image else {
            imageView.image = nil
            return
        }

        imageView.image = UIImage(data: image)
    }

    public func setupGroup(size: AvatarView.Size) {
        switch size {
        case .small:
            layer.cornerRadius = 13.0
        case .medium:
            layer.cornerRadius = 13.0
        case .large:
            layer.cornerRadius = 18.0
        }

        imageView.image = nil
        monogramLabel.text = nil
        iconImageView.image = Asset.sharedGroup.image
    }
}
