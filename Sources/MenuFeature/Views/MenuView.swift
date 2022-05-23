import UIKit
import Shared

final class MenuView: UIView {
    let headerView = MenuHeaderView()
    let stackView = UIStackView()
    let scanButton = MenuSectionButton()
    let chatsButton = MenuSectionButton()
    let contactsButton = MenuSectionButton()
    let requestsButton = MenuSectionButton()
    let settingsButton = MenuSectionButton()
    let dashboardButton = MenuSectionButton()
    let joinButton = MenuSectionButton()
    let infoStackView = UIStackView()
    let buildLabel = UILabel()
    let versionLabel = UILabel()
    let xxdkVersionLabel = UILabel()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        backgroundColor = Asset.neutralDark.color

        chatsButton.set(
            title: Localized.Menu.chats,
            image: Asset.menuChats.image,
            color: Asset.brandPrimary.color
        )

        scanButton.set(title: Localized.Menu.scan, image: Asset.menuScan.image)
        requestsButton.set(title: Localized.Menu.requests, image: Asset.menuRequests.image)
        contactsButton.set(title: Localized.Menu.contacts, image: Asset.menuContacts.image)
        settingsButton.set(title: Localized.Menu.settings, image: Asset.menuSettings.image)
        dashboardButton.set(title: Localized.Menu.dashboard, image: Asset.menuDashboard.image)
        joinButton.set(title: "Join xx network", image: Asset.permissionLogo.image)

        stackView.addArrangedSubview(chatsButton)
        stackView.addArrangedSubview(contactsButton)
        stackView.addArrangedSubview(requestsButton)
        stackView.addArrangedSubview(scanButton)
        stackView.addArrangedSubview(settingsButton)
        stackView.addArrangedSubview(dashboardButton)
        stackView.addArrangedSubview(joinButton)

        infoStackView.spacing = 10
        infoStackView.axis = .vertical
        [buildLabel, versionLabel, xxdkVersionLabel].forEach {
            $0.textColor = Asset.neutralWeak.color
            $0.font = Fonts.Mulish.regular.font(size: 12.0)
            infoStackView.addArrangedSubview($0)
        }

        stackView.spacing = 28
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing

        addSubview(headerView)
        addSubview(stackView)
        addSubview(infoStackView)

        setupConstraints()
        setupAccessibility()
    }

    private func setupConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-24)
        }

        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(26)
            make.top.equalTo(headerView.snp.bottom).offset(75)
        }

        infoStackView.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            make.left.equalToSuperview().offset(20)
        }
    }

    private func setupAccessibility() {
        scanButton.accessibilityIdentifier = Localized.Accessibility.Menu.scan
        chatsButton.accessibilityIdentifier = Localized.Accessibility.Menu.chats
        headerView.accessibilityIdentifier = Localized.Accessibility.Menu.header
        contactsButton.accessibilityIdentifier = Localized.Accessibility.Menu.contacts
        requestsButton.accessibilityIdentifier = Localized.Accessibility.Menu.requests
        settingsButton.accessibilityIdentifier = Localized.Accessibility.Menu.settings
    }
}
