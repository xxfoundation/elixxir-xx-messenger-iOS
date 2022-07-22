import UIKit
import Shared

final class ContactListActionButton: UIControl {
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let stackView = UIStackView()
    private let notificationLabel = UILabel()

    init() {
        super.init(frame: .zero)

        titleLabel.textColor = Asset.brandPrimary.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)

        notificationLabel.layer.cornerRadius = 5
        notificationLabel.layer.masksToBounds = true
        notificationLabel.textColor = Asset.neutralWhite.color
        notificationLabel.backgroundColor = Asset.brandPrimary.color
        notificationLabel.font = Fonts.Mulish.black.font(size: 12.0)

        stackView.spacing = 16
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(notificationLabel)
        stackView.addArrangedSubview(FlexibleSpace())
        stackView.setCustomSpacing(6, after: titleLabel)
        stackView.isUserInteractionEnabled = false

        addSubview(stackView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    func setup(title: String, image: UIImage) {
        titleLabel.text = title
        imageView.image = image
    }

    func updateNotification(_ count: Int) {
        notificationLabel.isHidden = count < 1
        notificationLabel.text = "  \(count)  " // TODO: Use insets (?) for padding
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.width.equalTo(25)
            $0.height.equalTo(25)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
