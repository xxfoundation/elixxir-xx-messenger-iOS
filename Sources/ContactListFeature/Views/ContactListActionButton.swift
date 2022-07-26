import UIKit
import Shared

final class ContactListActionButton: UIControl {
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let stackView = UIStackView()
    private let notificationLabel = UILabel()
    private let notificationContainerView = UIView()

    init() {
        super.init(frame: .zero)

        titleLabel.textColor = Asset.brandPrimary.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 14.0)

        notificationLabel.textColor = Asset.neutralWhite.color
        notificationLabel.font = Fonts.Mulish.bold.font(size: 12.0)

        notificationContainerView.isHidden = true
        notificationContainerView.layer.cornerRadius = 10
        notificationContainerView.layer.masksToBounds = true
        notificationContainerView.addSubview(notificationLabel)
        notificationContainerView.backgroundColor = Asset.brandPrimary.color

        stackView.spacing = 16
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(notificationContainerView)
        stackView.addArrangedSubview(FlexibleSpace())
        stackView.setCustomSpacing(8, after: titleLabel)
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
        notificationLabel.text = "\(count)"
        notificationContainerView.isHidden = count == 0
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.width.equalTo(25)
            $0.height.equalTo(25)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        notificationLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(8)
            $0.right.equalToSuperview().offset(-8)
        }
    }
}
