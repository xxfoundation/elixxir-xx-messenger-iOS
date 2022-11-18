import UIKit
import Shared
import AppResources

final class ContactSuccessView: UIView {
    // MARK: UI

    let stack = UIStackView()
    let keepAdding = CapsuleButton()
    let sentRequests = CapsuleButton()
    let buttons = SheetCardComponent()

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: Private

    private func setup() {
        keepAdding.setStyle(.brandColored)
        keepAdding.setTitle(Localized.Contact.Success.keepAdding, for: .normal)

        sentRequests.setStyle(.brandColored)
        sentRequests.setTitle(Localized.Contact.Success.sentRequests, for: .normal)

        buttons.set(buttons: [keepAdding, sentRequests])

        stack.axis = .vertical
        stack.spacing = 25

        addSubview(stack)
        addSubview(buttons)

        setupConstraints()
    }

    private func setupConstraints() {
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }

        buttons.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(stack.snp.bottom).offset(24)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
