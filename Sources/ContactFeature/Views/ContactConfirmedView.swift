import UIKit
import Shared

final class ContactConfirmedView: UIView {
    let stackView = UIStackView()
    let clearButton = CapsuleButton()
    let buttons = SheetCardComponent()

    init() {
        super.init(frame: .zero)

        clearButton.setStyle(.seeThrough)
        clearButton.setTitle(Localized.Contact.Confirmed.clear, for: .normal)
        
        buttons.set(buttons: [clearButton])

        stackView.axis = .vertical
        stackView.spacing = 25

        addSubview(stackView)
        addSubview(buttons)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }

        buttons.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(stackView.snp.bottom).offset(24)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }
}
