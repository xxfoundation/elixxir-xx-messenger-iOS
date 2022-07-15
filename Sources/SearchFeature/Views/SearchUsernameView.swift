import UIKit
import Shared

final class SearchUsernameView: UIView {
    let inputField = SearchComponent()
    let placeholderView = SearchUsernamePlaceholderView()

    init() {
        super.init(frame: .zero)

        inputField.set(
            placeholder: Localized.Ud.Search.Username.input,
            imageAtRight: nil
        )

        addSubview(inputField)
        addSubview(placeholderView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    private func setupConstraints() {
        inputField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }

        placeholderView.snp.makeConstraints {
            $0.top.equalTo(inputField.snp.bottom)
            $0.left.equalToSuperview().offset(32.5)
            $0.right.equalToSuperview().offset(-32.5)
            $0.bottom.equalToSuperview()
        }
    }
}
