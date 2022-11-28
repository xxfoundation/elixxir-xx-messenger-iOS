import UIKit
import Shared
import AppResources

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

    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(24)
      $0.left.equalToSuperview().offset(24)
      $0.right.equalToSuperview().offset(-24)
    }

    buttons.snp.makeConstraints {
      $0.top.greaterThanOrEqualTo(stackView.snp.bottom).offset(24)
      $0.left.equalToSuperview()
      $0.right.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) { nil }
}
