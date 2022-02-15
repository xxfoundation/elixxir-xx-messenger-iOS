import UIKit
import Shared

final class AttributeSwitcher: UIView {
    let contentLabel = UILabel()
    let titleLabel = UILabel()
    let iconImageView = UIImageView()
    let separatorView = UIView()
    let switcherView = UISwitch()
    let stackView = UIStackView()
    let verticalStackView = UIStackView()

    public init() {
        super.init(frame: .zero)

        contentLabel.textColor = Asset.neutralActive.color
        titleLabel.textColor = Asset.neutralWeak.color
        switcherView.onTintColor = Asset.brandPrimary.color
        separatorView.backgroundColor = Asset.neutralLine.color

        iconImageView.contentMode = .center
        iconImageView.setContentHuggingPriority(.required, for: .horizontal)

        contentLabel.numberOfLines = 0
        contentLabel.font = Fonts.Mulish.regular.font(size: 16.0)
        titleLabel.font = Fonts.Mulish.bold.font(size: 12.0)

        addSubview(stackView)
        addSubview(separatorView)

        verticalStackView.spacing = 8
        verticalStackView.axis = .vertical
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(contentLabel)

        let icon = iconImageView.pinning(at: .top(10))

        stackView.spacing = 20
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(verticalStackView)
        stackView.addArrangedSubview(switcherView.pinning(at: .top(5)))

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(26)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-25)
        }

        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    func set(
        title: String,
        text: String,
        icon: UIImage,
        separator: Bool = true
    ) {
        titleLabel.text = title
        contentLabel.text = text
        iconImageView.image = icon

        guard separator == true else {
            self.separatorView.removeFromSuperview()
            return
        }
    }
}
