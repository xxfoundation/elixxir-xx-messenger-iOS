import UIKit
import Shared
import Combine

public final class OutlinedInputField: UIView {
    let textField = UITextField()
    let placeholderLabel = UILabel()

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
        placeholderLabel.textColor = Asset.neutralWeak.color
        placeholderLabel.font = Fonts.Mulish.regular.font(size: 16.0)

        addSubview(placeholderLabel)
        addSubview(textField)

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
    }

    required init?(coder: NSCoder) { nil }

    public func setup(title: String) {
        placeholderLabel.text = title
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
