import UIKit
import Shared

final class FilterItemView: UIControl {
    enum Style {
        case selected
        case unselected
    }

    private let title = UILabel()
    private let image = UIImageView()

    private var icon: UIImage?

    var style: Style = .unselected {
        didSet {
            image.image = icon?.withRenderingMode(.alwaysTemplate)

            switch style {
            case .selected:
                backgroundColor = Asset.brandDefault.color
                image.tintColor = Asset.neutralWhite.color
                title.textColor = Asset.neutralWhite.color
                title.font = Fonts.Mulish.bold.font(size: 14.0)
                layer.borderColor = Asset.brandDefault.color.cgColor

            case .unselected:
                image.tintColor = Asset.neutralActive.color
                title.textColor = Asset.neutralActive.color
                backgroundColor = Asset.neutralSecondary.color
                title.font = Fonts.Mulish.regular.font(size: 14.0)
                layer.borderColor = Asset.neutralLine.color.cgColor
            }
        }
    }

    init() {
        super.init(frame: .zero)

        layer.borderWidth = 1
        layer.cornerRadius = 4
        image.contentMode = .center

        let stack = UIStackView()
        stack.isUserInteractionEnabled = false

        stack.spacing = 8
        stack.addArrangedSubview(image)
        stack.addArrangedSubview(title)

        addSubview(stack)

        stack.snp.makeConstraints { $0.center.equalToSuperview() }
        snp.makeConstraints { $0.height.equalTo(40) }
    }

    required init?(coder: NSCoder) { nil }

    func set(
        title: String,
        icon: UIImage?,
        style: Style = .unselected
    ) {
        self.icon = icon
        self.style = style
        self.title.text = title
    }
}
