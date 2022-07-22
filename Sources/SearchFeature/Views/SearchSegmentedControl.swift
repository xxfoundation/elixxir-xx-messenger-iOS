import UIKit
import Shared
import SnapKit
import Combine

final class SearchSegmentedControl: UIView {
    enum Item: Int {
        case username = 0
        case email
        case phone
        case qr

        var written: String {
            switch self {
            case .qr: return "qr"
            case .email: return "email"
            case .phone: return "phone number"
            case .username: return "username"
            }
        }
    }

    private let trackView = UIView()
    private let stackView = UIStackView()
    private var leftConstraint: Constraint?
    private let trackIndicatorView = UIView()
    private let emailButton = SearchSegmentedButton()
    private let phoneButton = SearchSegmentedButton()
    private let qrCodeButton = SearchSegmentedButton()
    private let usernameButton = SearchSegmentedButton()

    var actionPublisher: AnyPublisher<Item, Never> {
        actionSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let actionSubject = CurrentValueSubject<Item, Never>(.username)

    init() {
        super.init(frame: .zero)
        trackView.backgroundColor = Asset.neutralLine.color
        trackIndicatorView.backgroundColor = Asset.brandPrimary.color

        qrCodeButton.setup(title: Localized.Ud.Tab.qr, icon: Asset.searchTabQr.image)
        emailButton.setup(title: Localized.Ud.Tab.email, icon: Asset.searchTabEmail.image)
        phoneButton.setup(title: Localized.Ud.Tab.phone, icon: Asset.searchTabPhone.image)
        usernameButton.setup(title: Localized.Ud.Tab.username, icon: Asset.searchTabUsername.image)

        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(usernameButton)
        stackView.addArrangedSubview(emailButton)
        stackView.addArrangedSubview(phoneButton)
        stackView.addArrangedSubview(qrCodeButton)
        stackView.backgroundColor = Asset.neutralWhite.color

        addSubview(stackView)
        addSubview(trackView)
        trackView.addSubview(trackIndicatorView)

        setupBindings()
        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    private func setupBindings() {
        usernameButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in actionSubject.send(.username) }
            .store(in: &cancellables)

        emailButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in actionSubject.send(.email) }
            .store(in: &cancellables)

        phoneButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in actionSubject.send(.phone) }
            .store(in: &cancellables)

        qrCodeButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in actionSubject.send(.qr) }
            .store(in: &cancellables)

        actionSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                let tabWidth = bounds.width / 4
                if let leftConstraint = leftConstraint {
                    leftConstraint.update(offset: tabWidth * CGFloat($0.rawValue))
                    setNeedsLayout()
                    UIView.animate(withDuration: 0.25) { self.layoutIfNeeded() }
                }

                qrCodeButton.setSelected($0 == .qr)
                emailButton.setSelected($0 == .email)
                phoneButton.setSelected($0 == .phone)
                usernameButton.setSelected($0 == .username)
            }.store(in: &cancellables)
    }

    private func setupConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        trackView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
        }

        trackIndicatorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            leftConstraint = $0.left.equalToSuperview().constraint
            $0.width.equalToSuperview().dividedBy(4)
            $0.bottom.equalToSuperview()
        }
    }
}
