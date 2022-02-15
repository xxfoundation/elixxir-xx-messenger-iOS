import UIKit

public final class AttributeComponent: UIView {
    public enum Style {
        case steady
        case interactive
        case requiredEditable
    }

    public let titleLabel = UILabel()
    public let actionButton = UIButton()
    public let contentLabel = UILabel()

    let placeholder = "None provided"
    var buttonStyle: Style = .steady

    public private(set) var currentValue: String? {
        didSet { contentLabel.text = currentValue ?? placeholder }
    }

    public init() {
        super.init(frame: .zero)

        titleLabel.textColor = Asset.neutralWeak.color
        contentLabel.textColor = Asset.neutralActive.color
        titleLabel.font =  Fonts.Mulish.bold.font(size: 12.0)
        contentLabel.font = Fonts.Mulish.regular.font(size: 16.0)

        addSubview(titleLabel)
        addSubview(actionButton)
        addSubview(contentLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.bottom.equalToSuperview().offset(-25)
        }

        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalToSuperview()
        }

        actionButton.snp.makeConstraints { $0.right.centerY.equalToSuperview() }
    }

    required init?(coder: NSCoder) { nil }

    public func set(
        title: String,
        value: String? = nil,
        icon: UIImage? = nil,
        style: Style = .steady
    ) {
        titleLabel.text = title.uppercased()
        actionButton.setImage(icon, for: .normal)
        buttonStyle = style

        set(value: value)
    }

    public func set(value: String?) {
        currentValue = value

        if buttonStyle == .requiredEditable {
            actionButton.setImage(Asset.contactNicknameEdit.image, for: .normal)
            return
        }

        guard let _ = value else {
            if buttonStyle == .interactive {
                actionButton.setImage(Asset.profileAdd.image, for: .normal)
            }

            return
        }

        if buttonStyle == .interactive {
            actionButton.setImage(Asset.profileDelete.image, for: .normal)
        }
    }
}
