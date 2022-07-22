import UIKit

final class AvatarCellButton: UIControl {
    private let titleLabel = UILabel()
    private let imageView = UIImageView()

    init() {
        super.init(frame: .zero)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .right
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 13.0)

        addSubview(imageView)
        addSubview(titleLabel)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    func prepareForReuse() {
        titleLabel.text = nil
        imageView.image = nil
    }

    func set(
        image: UIImage?,
        title: String,
        titleColor: UIColor
    ) {
        imageView.image = image
        titleLabel.text = title
        titleLabel.textColor = titleColor
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.top.greaterThanOrEqualToSuperview()
            $0.left.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.greaterThanOrEqualToSuperview()
            $0.left.equalTo(imageView.snp.right).offset(5)
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview()
            $0.width.equalTo(60)
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
}
