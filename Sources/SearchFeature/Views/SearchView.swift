import UIKit
import Shared
import InputField

final class SearchView: UIView {
    private enum Constants {
        static let phone = Localized.ContactSearch.Filter.phone
        static let email = Localized.ContactSearch.Filter.email
        static let username = Localized.ContactSearch.Filter.username
    }

    let input = InputField()
    let stack = UIStackView()
    let filters = UIStackView()
    let email = FilterItemView()
    let phone = FilterItemView()
    let empty = SearchEmptyView()
    let phoneInput = InputField()
    let username = FilterItemView()
    lazy var placeholder = SearchPlaceholderView { self.didTapInfo() }

    let didTapInfo: () -> Void

    init(didTapInfo: @escaping () -> Void) {
        self.didTapInfo = didTapInfo

        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    func alternateFieldsOver(filter: SelectedFilter) {
        switch filter {
        case .username, .email:
            input.isHidden = false
            phoneInput.isHidden = true
        case .phone:
            input.isHidden = true
            phoneInput.isHidden = false
        }
    }

    func select(filter: SelectedFilter) {
        [username, email, phone].forEach { $0.style = .unselected }

        switch filter {
        case .username:
            username.style = .selected
            empty.set(filter: Constants.username.lowercased())
            input.makeFirstResponder()
        case .email:
            email.style = .selected
            empty.set(filter: Constants.email.lowercased())
            input.makeFirstResponder()
        case .phone:
            phone.style = .selected
            empty.set(filter: Constants.phone.lowercased())
            phoneInput.makeFirstResponder()
        }
    }

    // MARK: Private

    private func setup() {
        backgroundColor = Asset.neutralWhite.color

        input.setup(
            placeholder: Localized.ContactSearch.title,
            leftView: .image(Asset.lens.image.withTintColor(Asset.neutralDisabled.color)),
            accessibility: Localized.Accessibility.Search.input,
            allowsEmptySpace: false,
            autocapitalization: .none,
            returnKeyType: .search,
            clearable: true
        )

        phoneInput.setup(
            style: .phone,
            placeholder: "1509192596",
            rightView: .image(Asset.searchLens.image),
            accessibility: Localized.Accessibility.Search.phoneInput,
            keyboardType: .numberPad,
            contentType: .telephoneNumber,
            returnKeyType: .search,
            toolbarButtonTitle: Localized.Shared.Search.placeholder,
            codeAccessibility: Localized.Accessibility.Search.countryCode
        )

        email.set(title: Constants.email, icon: Asset.searchEmail.image)
        phone.set(title: Constants.phone, icon: Asset.searchPhone.image)
        username.set(title: Constants.username, icon: Asset.searchUsername.image, style: .selected)

        email.accessibilityIdentifier = Localized.Accessibility.Search.email
        phone.accessibilityIdentifier = Localized.Accessibility.Search.phone
        username.accessibilityIdentifier = Localized.Accessibility.Search.username

        filters.addArrangedSubview(username)
        filters.addArrangedSubview(email)
        filters.addArrangedSubview(phone)
        filters.distribution = .fillEqually
        filters.spacing = 20

        stack.axis = .vertical
        stack.addArrangedSubview(filters)
        stack.addArrangedSubview(input)
        stack.addArrangedSubview(phoneInput)

        addSubview(stack)
        addSubview(empty)
        addSubview(placeholder)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(17)
            make.right.equalToSuperview().offset(-17)
        }

        placeholder.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }

        empty.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }
}
