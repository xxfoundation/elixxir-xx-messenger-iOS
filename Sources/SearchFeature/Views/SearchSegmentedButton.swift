import UIKit
import Shared

final class SearchSegmentedButton: UIControl {
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let highlightColor = Asset.brandPrimary.color
    private let discreteColor = Asset.neutralDisabled.color

    init() {
        super.init(frame: .zero)

        imageView.contentMode = .center
        titleLabel.textAlignment = .center
        titleLabel.textColor = Asset.neutralWhite.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 13.0)

        addSubview(titleLabel)
        addSubview(imageView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    func setup(
        title: String,
        icon: UIImage,
        iconColor: UIColor = Asset.neutralDisabled.color,
        titleColor: UIColor = Asset.neutralDisabled.color
    ) {
        self.imageView.image = icon
        self.titleLabel.text = title
        self.imageView.tintColor = iconColor
        self.titleLabel.textColor = titleColor
    }

    func updateHighlighting(rate: CGFloat) {
        let color = UIColor.fade(
            from: discreteColor,
            to: highlightColor,
            pcent: rate
        )

        imageView.tintColor = color
        titleLabel.textColor = color
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(7.5)
            $0.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-7.5)
        }
    }
}
