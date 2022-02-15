import UIKit
import Shared

final class ActionButton: UIControl {

    let titleLabel = UILabel()
    let imageView = UIImageView()
    let imageBackgroundView = UIView()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    func setup(title: String, image: UIImage) {
        titleLabel.text = title
        imageView.image = image
    }

    private func setup() {
        imageBackgroundView.layer.cornerRadius = 4
        titleLabel.textColor = Asset.neutralDark.color
        titleLabel.font = Fonts.Mulish.semiBold.font(size: 10.0)
        imageBackgroundView.backgroundColor = Asset.neutralSecondary.color

        addSubview(titleLabel)
        addSubview(imageBackgroundView)
        imageBackgroundView.addSubview(imageView)

        imageView.isUserInteractionEnabled = false
        imageBackgroundView.isUserInteractionEnabled = false

        imageView.snp.makeConstraints { $0.center.equalToSuperview() }

        imageBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(imageBackgroundView.snp.height)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageBackgroundView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
