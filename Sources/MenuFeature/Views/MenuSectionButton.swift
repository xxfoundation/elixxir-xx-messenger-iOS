import UIKit
import Shared

final class MenuSectionButton: UIControl {
    let titleLabel = UILabel()
    let imageView = UIImageView()
    let stackView = UIStackView()
    let notificationLabel = UILabel()

    init() {
        super.init(frame: .zero)

        imageView.contentMode = .scaleAspectFit
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)
        imageView.setContentHuggingPriority(.required, for: .horizontal)

        notificationLabel.isHidden = true
        notificationLabel.layer.cornerRadius = 5
        notificationLabel.layer.masksToBounds = true
        notificationLabel.textColor = Asset.neutralWhite.color
        notificationLabel.backgroundColor = Asset.brandPrimary.color
        notificationLabel.font = Fonts.Mulish.bold.font(size: 12.0)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(notificationLabel)
        stackView.setCustomSpacing(12, after: imageView)
        stackView.setCustomSpacing(6, after: titleLabel)
        addSubview(stackView)

        stackView.isUserInteractionEnabled = false
        imageView.snp.makeConstraints { $0.width.equalTo(23) }
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) { nil }

    func updateNotification(_ count: Int) {
        notificationLabel.isHidden = count < 1
        notificationLabel.text = "  \(count)  "
    }

    func set(color: UIColor) {
        titleLabel.textColor = color

        if let image = imageView.image {
            imageView.image = image.withTintColor(color)
        }
    }

    func set(title: String, image: UIImage) {
        titleLabel.text = title
        titleLabel.textColor = Asset.neutralWeak.color
        imageView.image = image.withTintColor(Asset.neutralWeak.color)
    }
}
