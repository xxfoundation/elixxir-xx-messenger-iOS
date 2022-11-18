import UIKit
import Shared
import AppResources

final class SheetButton: UIControl {
    enum Style {
        case normal
        case destructive
    }

    // MARK: UI

    let title = UILabel()
    let image = UIImageView()

    // MARK: Properties

    private let style: Style
    override var isEnabled: Bool {
        didSet {
            title.alpha = isEnabled ? 1.0 : 0.5
            image.alpha = isEnabled ? 1.0 : 0.5
        }
    }

    // MARK: Lifecycle

    init(_ style: Style = .normal) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Private

    private func setup() {
        title.font = Fonts.Mulish.bold.font(size: 14.0)
        title.textColor = style == .normal ? Asset.neutralBody.color : Asset.neutralBody.color

        addSubview(title)
        addSubview(image)

        image.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.centerY.equalToSuperview()
        }

        title.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(84)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().offset(16)
        }
    }
}
