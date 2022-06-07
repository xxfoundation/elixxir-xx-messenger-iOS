import UIKit
import Combine

public final class SearchComponent: UIView {
    let rightButton = UIButton()
    let leftImageView = UIImageView()
    let containerView = UIView()
    let inputField = UITextField()

    public var rightPublisher: AnyPublisher<Void, Never> {
        rightSubject.eraseToAnyPublisher()
    }

    public var textPublisher: AnyPublisher<String, Never> {
        textSubject.eraseToAnyPublisher()
    }

    private var rightImage = Asset.sharedScan.image {
        didSet {
            rightButton.setImage(rightImage, for: .normal)
        }
    }

    public var isEditingPublisher: AnyPublisher<Bool, Never> {
        isEditingSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private var rightSubject = PassthroughSubject<Void, Never>()
    private var textSubject = PassthroughSubject<String, Never>()
    private var isEditingSubject = CurrentValueSubject<Bool, Never>(false)

    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    public func set(
        placeholder: String? = nil,
        imageAtRight: UIImage? = nil,
        inputAccessibility: String? = nil,
        rightAccessibility: String? = nil
    ) {
        inputField.accessibilityIdentifier = inputAccessibility
        rightButton.accessibilityIdentifier = rightAccessibility

        if let placeholder = placeholder {
            let attrPlaceholder
                = NSAttributedString(
                    string: placeholder,
                    attributes: [
                        .font: Fonts.Mulish.regular.font(size: 14.0) as Any,
                        .foregroundColor: Asset.neutralWeak.color
                    ])

            inputField.attributedPlaceholder = attrPlaceholder
        }

        if let image = imageAtRight {
            self.rightImage = image
        } else {
            rightButton.isHidden = true
        }
    }

    public func update(placeholder: String) {
        inputField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .font: Fonts.Mulish.regular.font(size: 14.0) as Any,
                .foregroundColor: Asset.neutralWeak.color
        ])
    }

    public func abortEditing() {
        inputField.text = nil
        textSubject.send("")
        inputField.endEditing(true)
        isEditingSubject.send(false)
    }

    private func setup() {
        containerView.layer.cornerRadius = 25
        containerView.backgroundColor = Asset.neutralSecondary.color

        leftImageView.image = Asset.lens.image
        leftImageView.contentMode = .center
        leftImageView.tintColor = Asset.neutralDisabled.color

        rightButton.tintColor = Asset.neutralBody.color
        rightButton.setImage(rightImage, for: .normal)
        rightButton.setContentHuggingPriority(.required, for: .horizontal)
        rightButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        inputField.delegate = self
        inputField.textColor = Asset.neutralActive.color
        inputField.font = Fonts.Mulish.regular.font(size: 16.0)

        let attrPlaceholder
            = NSAttributedString(
                string: Localized.Shared.Search.placeholder,
                attributes: [
                    .font: Fonts.Mulish.regular.font(size: 14.0) as Any,
                    .foregroundColor: Asset.neutralWeak.color
                ])

        inputField.attributedPlaceholder = attrPlaceholder

        inputField.textPublisher
            .sink { [weak textSubject] in textSubject?.send($0) }
            .store(in: &cancellables)

        rightButton.publisher(for: .touchUpInside)
            .sink { [weak rightSubject, self] in
                if isEditingSubject.value == true {
                    abortEditing()
                } else {
                    rightSubject?.send()
                }
            }.store(in: &cancellables)

        addSubview(containerView)
        containerView.addSubview(inputField)
        containerView.addSubview(leftImageView)
        containerView.addSubview(rightButton)

        setupConstraints()
        setupAccessibility()
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(50)
        }

        leftImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(13)
            $0.bottom.equalToSuperview().offset(-10)
            $0.height.equalTo(leftImageView.snp.width)
        }

        inputField.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalTo(leftImageView.snp.right).offset(20)
            $0.right.equalTo(rightButton.snp.left).offset(-32)
        }

        rightButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.right.equalToSuperview().offset(-13)
            $0.bottom.equalToSuperview()
        }
    }

    private func setupAccessibility() {
        inputField.accessibilityIdentifier = Localized.Accessibility.Shared.Search.textField
        rightButton.accessibilityIdentifier = Localized.Accessibility.Shared.Search.rightButton
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        rightButton.setImage(Asset.sharedCross.image, for: .normal)
        isEditingSubject.send(true)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        rightButton.setImage(rightImage, for: .normal)
        isEditingSubject.send(false)
    }
}

extension SearchComponent: UITextFieldDelegate {}
