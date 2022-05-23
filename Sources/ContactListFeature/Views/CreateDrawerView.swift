import UIKit
import Shared
import InputField

final class CreateDrawerView: UIView {
    let titleLabel = UILabel()
    let subtitleView = TextWithInfoView()
    let inputField = InputField()
    let otherInputField = InputField()
    let stackView = UIStackView()
    let createButton = CapsuleButton()
    let cancelButton = CapsuleButton()

    var didTapInfo: (() -> Void)?

    init() {
        super.init(frame: .zero)

        layer.cornerRadius = 40
        backgroundColor = Asset.neutralWhite.color
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        titleLabel.textAlignment = .left
        titleLabel.text = Localized.CreateGroup.Drawer.title
        titleLabel.font = Fonts.Mulish.bold.font(size: 26.0)
        titleLabel.textColor = Asset.neutralActive.color

        inputField.setup(
            style: .regular,
            title: Localized.CreateGroup.Drawer.input,
            placeholder: Localized.CreateGroup.Drawer.placeholder,
            leftView: .image(Asset.personGray.image),
            accessibility: Localized.Accessibility.CreateGroup.Drawer.input,
            subtitleColor: Asset.neutralDisabled.color
        )

        otherInputField.setup(
            style: .regular,
            title: Localized.CreateGroup.Drawer.otherInput,
            placeholder: Localized.CreateGroup.Drawer.otherPlaceholder,
            leftView: .image(Asset.balloon.image),
            accessibility: Localized.Accessibility.CreateGroup.Drawer.otherInput,
            subtitleColor: Asset.neutralDisabled.color
        )

        createButton.set(
            style: .brandColored,
            title: Localized.CreateGroup.Drawer.action,
            accessibility: Localized.Accessibility.CreateGroup.Drawer.create
        )

        cancelButton.set(
            style: .seeThrough,
            title: Localized.CreateGroup.Drawer.cancel
        )

        stackView.spacing = 20
        stackView.axis = .vertical
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleView)
        stackView.addArrangedSubview(inputField)
        stackView.addArrangedSubview(otherInputField)
        stackView.addArrangedSubview(createButton)
        stackView.addArrangedSubview(cancelButton)

        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.left.equalToSuperview().offset(50)
            $0.right.equalToSuperview().offset(-50)
            $0.bottom.equalToSuperview().offset(-70)
        }
    }

    required init?(coder: NSCoder) { nil }

    func set(count: Int, didTap: @escaping () -> Void) {
        self.didTapInfo = didTap

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineHeightMultiple = 1.1

        subtitleView.setup(
            text: Localized.CreateGroup.Drawer.subtitle("\(count)"),
            attributes: [
                .paragraphStyle: paragraphStyle,
                .foregroundColor: Asset.neutralBody.color,
                .font: Fonts.Mulish.semiBold.font(size: 14.0) as Any
            ],
            didTapInfo: { [weak self] in self?.didTapInfo?() }
        )
    }

    func update(status: InputField.ValidationStatus) {
        inputField.update(status: status)

        switch status {
        case .valid:
            createButton.isEnabled = true
        case .invalid, .unknown:
            createButton.isEnabled = false
        }
    }
}
