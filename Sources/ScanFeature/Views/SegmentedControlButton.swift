import UIKit
import Shared

final class SegmentedControlButton: UIControl {
    private let titleLabel = UILabel()
    private let imageView = UIImageView()

    init() {
        super.init(frame: .zero)

        titleLabel.textAlignment = .center
        titleLabel.textColor = Asset.neutralWhite.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 13.0)

        addSubview(titleLabel)
        addSubview(imageView)

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

    required init?(coder: NSCoder) { nil }

    func setup(title: String, icon: UIImage) {
        titleLabel.text = title
        imageView.image = icon
    }

    func update(color: UIColor) {
        imageView.tintColor = color
        titleLabel.textColor = color
    }
}
