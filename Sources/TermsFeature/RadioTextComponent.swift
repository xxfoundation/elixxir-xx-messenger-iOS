import UIKit
import Shared

final class RadioTextComponent: UIView {
    let titleLabel = UILabel()
    let radioButton = RadioButton()

    var isEnabled: Bool = false {
        didSet { radioButton.set(enabled: isEnabled) }
    }

    init() {
        super.init(frame: .zero)

        titleLabel.numberOfLines = 0
        titleLabel.textColor = Asset.neutralBody.color
        titleLabel.font = Fonts.Mulish.regular.font(size: 13.0)

        addSubview(titleLabel)
        addSubview(radioButton)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(radioButton.snp.right).offset(7)
            $0.centerY.equalTo(radioButton)
            $0.right.equalToSuperview()
        }

        radioButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
