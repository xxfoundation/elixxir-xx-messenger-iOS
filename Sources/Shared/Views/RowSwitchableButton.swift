import UIKit

public enum RowSwitchableButtonState {
    case disclosure
    case switcher(Bool)
}

public final class RowSwitchableButton: UIControl {
    public let title = UILabel()
    public let icon = UIImageView()
    public let separator = UIView()

    public let switcher = UISwitch()
    public let disclosureIcon = UIImageView()

    public init() {
        super.init(frame: .zero)

        icon.contentMode = .center
        title.font = Fonts.Mulish.semiBold.font(size: 14.0)
        separator.backgroundColor = Asset.neutralLine.color
        title.textColor = Asset.neutralActive.color
        disclosureIcon.image = Asset.settingsDisclosure.image
        switcher.onTintColor = Asset.brandLight.color

        addSubview(icon)
        addSubview(title)
        addSubview(disclosureIcon)
        addSubview(switcher)
        addSubview(separator)

        icon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(36)
            make.bottom.equalToSuperview().offset(-20)
        }

        title.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(25)
            make.centerY.equalTo(icon)
        }

        disclosureIcon.snp.makeConstraints { make in
            make.centerY.equalTo(icon)
            make.right.equalToSuperview().offset(-48)
        }

        switcher.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25)
            make.centerY.equalTo(icon)
        }

        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview()
        }
    }

    public required init?(coder: NSCoder) { nil }

    public func setup(
        title: String,
        icon: UIImage,
        state: RowSwitchableButtonState = .disclosure,
        separator: Bool = true
    ) {
        self.icon.image = icon
        self.title.text = title

        switch state {
        case .disclosure:
            switcher.isHidden = true
            disclosureIcon.isHidden = false

        case .switcher(let bool):
            switcher.isOn = bool
            switcher.isHidden = false
            disclosureIcon.isHidden = true
        }

        guard separator == true else {
            self.separator.removeFromSuperview()
            return
        }
    }
}
