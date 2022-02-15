import UIKit
import Shared
import InputField

final class NickameView: UIView {
    // MARK: UI

    let title = UILabel()
    let icon = UIImageView()
    let input = InputField()
    let stack = UIStackView()
    let save = CapsuleButton()

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    func update(status: InputField.ValidationStatus) {
        input.update(status: status)

        switch status {
        case .valid:
            save.isEnabled = true
        case .invalid, .unknown:
            save.isEnabled = false
        }
    }

    // MARK: Private

    private func setup() {
        layer.cornerRadius = 40
        backgroundColor = Asset.neutralWhite.color
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        icon.contentMode = .center
        title.textColor = Asset.neutralDark.color
        icon.image = Asset.personPlaceholder.image

        input.setup(
            style: .regular,
            title: Localized.Contact.Nickname.input,
            placeholder: "Jim Morrison",
            leftView: .image(Asset.personGray.image),
            subtitleColor: Asset.neutralDisabled.color
        )

        title.text = Localized.Contact.Nickname.title
        title.textAlignment = .center
        title.font = Fonts.Mulish.semiBold.font(size: 18.0)

        save.setStyle(.brandColored)
        save.setTitle(Localized.Contact.Nickname.save, for: .normal)

        stack.spacing = 20
        stack.axis = .vertical
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(input)
        stack.addArrangedSubview(save)

        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
}
