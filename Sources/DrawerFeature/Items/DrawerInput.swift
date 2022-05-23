import UIKit
import Shared
import Combine
import InputField

public struct DrawerInputValidator {
    let wrongIcon: InputField.RightView
    let correctIcon: InputField.RightView
    let shouldAcceptPlaceholder: Bool

    public init(
        wrongIcon: InputField.RightView,
        correctIcon: InputField.RightView,
        shouldAcceptPlaceholder: Bool
    ) {
        self.wrongIcon = wrongIcon
        self.correctIcon = correctIcon
        self.shouldAcceptPlaceholder = shouldAcceptPlaceholder
    }
}

public final class DrawerInput: DrawerItem {
    public var inputPublisher: AnyPublisher<String, Never> {
        inputSubject.eraseToAnyPublisher()
    }

    public var validationPublisher: AnyPublisher<Bool, Never> {
        validationSubject.eraseToAnyPublisher()
    }

    private let placeholder: String
    private let validator: DrawerInputValidator?
    private var cancellables = Set<AnyCancellable>()
    private let inputSubject = PassthroughSubject<String, Never>()
    private let validationSubject = CurrentValueSubject<Bool, Never>(true)

    public var spacingAfter: CGFloat? = 0

    public init(
        placeholder: String,
        validator: DrawerInputValidator? = nil,
        spacingAfter: CGFloat = 10
    ) {
        self.validator = validator
        self.placeholder = placeholder
        self.spacingAfter = spacingAfter
    }

    public func makeView() -> UIView {
        let view = InputField()
        view.setup(style: .regular, placeholder: placeholder)

        if let validator = validator {
            if validator.shouldAcceptPlaceholder {
                view.set(rightView: validator.correctIcon)
            }
        }

        func validate(string: String, using validator: DrawerInputValidator) {
            if string.isEmpty && validator.shouldAcceptPlaceholder {
                view.set(rightView: validator.correctIcon)
                validationSubject.send(true)
                return
            }

            if string.isEmpty && !validator.shouldAcceptPlaceholder {
                view.set(rightView: validator.wrongIcon)
                validationSubject.send(false)
                return
            }

            if string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                view.set(rightView: validator.wrongIcon)
                validationSubject.send(false)
                return
            }
        }

        view.textPublisher
            .sink { [weak self] in
                if let validator = self?.validator {
                    validate(string: $0, using: validator)
                }

                self?.inputSubject.send($0)
            }
            .store(in: &cancellables)

        return view
    }
}
