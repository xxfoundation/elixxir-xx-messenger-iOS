import UIKit
import Shared
import InputField

final class SearchUsernameView: UIView {
    let inputField = InputField()
    let placeholderView = SearchUsernamePlaceholderView()

    init() {
        super.init(frame: .zero)

        inputField.setup(
            style: .regular,
            title: "Username",
            placeholder: "Username"
        )

        addSubview(inputField)
        addSubview(placeholderView)

        inputField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }

        placeholderView.snp.makeConstraints {
            $0.top.equalTo(inputField.snp.bottom)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }
}
