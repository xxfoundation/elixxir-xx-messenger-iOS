import UIKit
import Shared

final class PhoneCodeField: UIButton {
    // MARK: UI

    public let content = UILabel()

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder: NSCoder) { nil }

    // MARK: Private

    private func setup() {
        content.textColor = Asset.neutralActive.color
        content.font = Fonts.Mulish.semiBold.font(size: 14.0)

        addSubview(content)

        content.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
            make.width.equalTo(60)
            make.bottom.equalToSuperview()
        }
    }
}
