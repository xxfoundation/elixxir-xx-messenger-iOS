import UIKit

public final class DetailRowButton: UIControl {
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    let rowIndicator = UIImageView()

    public init() {
        super.init(frame: .zero)

        rowIndicator.contentMode = .center
        rowIndicator.image = Asset.settingsDisclosure.image

        titleLabel.font = Fonts.Mulish.bold.font(size: 12.0)
        valueLabel.font = Fonts.Mulish.regular.font(size: 16.0)

        titleLabel.textColor = Asset.neutralWeak.color
        valueLabel.textColor = Asset.neutralActive.color

        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(rowIndicator)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        rowIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    public func setup(title: String, value: String, hasArrow: Bool = true) {
        titleLabel.text = title
        valueLabel.text = value
        rowIndicator.isHidden = !hasArrow
    }
}
