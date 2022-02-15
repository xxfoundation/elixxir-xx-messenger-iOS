import UIKit

public final class SnackBar: UIView {
    // MARK: UI

    let title = UILabel()
    let icon = UIImageView()
    let stack = UIStackView()

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Private

    private func setup() {
        backgroundColor = Asset.brandPrimary.color

        icon.contentMode = .center
        title.text = "Connecting to xx network..."
        title.font = Fonts.Mulish.semiBold.font(size: 13.0)
        title.textColor = Asset.neutralWhite.color
        icon.image = Asset.sharedWhiteExclamation.image

        stack.spacing = 14
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(title)

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}
