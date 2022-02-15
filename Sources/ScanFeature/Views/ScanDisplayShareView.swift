import UIKit
import Shared

final class ScanDisplayShareView: UIView {
    let stackView = UIStackView()
    let textWithInfo = TextWithInfoView()
    let emailView = AttributeSwitcher()
    let phoneView = AttributeSwitcher()

    var didTapInfo: (() -> Void)?

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralWhite.color

        let titleContainer = UIView()
        titleContainer.addSubview(textWithInfo)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping

        textWithInfo.setup(
            text: Localized.Scan.Display.Share.title,
            attributes: [
                .foregroundColor: Asset.neutralBody.color,
                .font: Fonts.Mulish.regular.font(size: 16.0) as Any,
                .paragraphStyle: paragraphStyle
            ],
            didTapInfo: { [weak self] in self?.didTapInfo?() }
        )

        stackView.spacing = 5
        stackView.axis = .vertical
        stackView.addArrangedSubview(titleContainer)

        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.left.equalToSuperview().offset(22)
            make.right.equalToSuperview().offset(-22)
            make.bottom.equalToSuperview().offset(-50)
        }

        textWithInfo.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.lessThanOrEqualToSuperview().offset(27)
            make.height.equalTo(30)
        }
    }

    required init?(coder: NSCoder) { nil }

    func setup(email: String) -> UIControl.EventPublisher {
        stackView.addArrangedSubview(emailView)

        emailView.set(
            title: Localized.Scan.Display.Share.email,
            text: email,
            icon: Asset.scanEmail.image
        )

        return emailView.switcherView.publisher(for: .valueChanged)
    }

    func setup(phone: String) -> UIControl.EventPublisher {
        stackView.addArrangedSubview(phoneView)

        phoneView.set(
            title: Localized.Scan.Display.Share.phone,
            text: phone,
            icon: Asset.scanPhone.image,
            separator: false
        )

        return phoneView.switcherView.publisher(for: .valueChanged)
    }
}
