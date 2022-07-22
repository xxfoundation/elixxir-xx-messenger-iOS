import UIKit
import Shared
import Combine

public final class OutlinedInputField: UIView {
    private let stackView = UIStackView()
    private let textField = UITextField()
    private let placeholderLabel = UILabel()
    private let inputContainerView = UIView()

    private let secureInputButton = SecureInputButton()

    public var textPublisher: AnyPublisher<String, Never> {
        textField.textPublisher
    }

    public init() {
        super.init(frame: .zero)

        layer.borderWidth = 1.0
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
        layer.borderColor = Asset.neutralWeak.color.cgColor

        textField.delegate = self
        textField.backgroundColor = .clear
        textField.textColor = Asset.neutralDark.color
        placeholderLabel.textColor = Asset.neutralWeak.color
        placeholderLabel.font = Fonts.Mulish.regular.font(size: 16.0)

        secureInputButton.button.addTarget(self, action: #selector(didTapRight), for: .touchUpInside)

        inputContainerView.addSubview(placeholderLabel)
        inputContainerView.addSubview(textField)

        stackView.addArrangedSubview(inputContainerView)
        stackView.addArrangedSubview(secureInputButton)

        addSubview(stackView)

        placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.left.equalToSuperview().offset(15)
            $0.right.lessThanOrEqualToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-18)
        }

        textField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-18)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    public func setup(title: String, sensitive: Bool = false) {
        placeholderLabel.text = title
        textField.isSecureTextEntry = sensitive
        secureInputButton.isHidden = !sensitive
    }

    @objc private func didTapRight() {
        textField.isSecureTextEntry.toggle()
        secureInputButton.setSecure(textField.isSecureTextEntry)
    }
}

extension OutlinedInputField: UITextFieldDelegate {
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        placeholderLabel.alpha = (textField.text! as NSString)
            .replacingCharacters(in: range, with: string)
            .count > 0 ? 0.0 : 1.0
        return true
    }
}
