import UIKit
import Shared
import SnapKit

final class ErrorView: UIView {
    // MARK: UI

    let title = UILabel()
    let content = UILabel()
    let stack = UIStackView()
    let button = CapsuleButton()

    // MARK: Lifecycle

    init(with model: HUDError) {
        super.init(frame: .zero)
        setup(with: model)
    }

    required init?(coder: NSCoder) { nil }
    

    // MARK: Private

    private func setup(with model: HUDError) {
        layer.cornerRadius = 6
        backgroundColor = Asset.neutralWhite.color

        title.text = model.title
        title.textColor = Asset.neutralBody.color
        title.font = Fonts.Mulish.bold.font(size: 35.0)
        title.textAlignment = .center
        title.numberOfLines = 0

        content.text = model.content
        content.textColor = Asset.neutralBody.color
        content.numberOfLines = 0
        content.font = Fonts.Mulish.regular.font(size: 14.0)
        content.textAlignment = .center

        button.setTitle(model.buttonTitle, for: .normal)
        button.setStyle(.brandColored)

        stack.axis = .vertical

        stack.addArrangedSubview(title)
        stack.addArrangedSubview(content)

        if model.dismissable {
            stack.addArrangedSubview(button)
        }

        stack.setCustomSpacing(25, after: title)
        stack.setCustomSpacing(59, after: content)

        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(57)
            make.right.equalToSuperview().offset(-57)
            make.bottom.equalToSuperview().offset(-35)
        }
    }
}
