import UIKit
import Shared
import InputField

final class SearchEmailView: UIView {
    let inputField = InputField()

    init() {
        super.init(frame: .zero)

        inputField.setup(
            style: .regular,
            title: "Email",
            placeholder: "Email"
        )

        addSubview(inputField)

        inputField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }
}
