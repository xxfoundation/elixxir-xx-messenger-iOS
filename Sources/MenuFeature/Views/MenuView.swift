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
        backgroundColor = Asset.neutralDark.color

        chatsButton.set(title: Localized.Menu.chats, image: Asset.menuChats.image)
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
    }

    required init?(coder: NSCoder) { nil }

    func select(item: MenuItem) {
        switch item {
        case .chats:
            chatsButton.set(color: Asset.brandPrimary.color)
        case .contacts:
            contactsButton.set(color: Asset.brandPrimary.color)
        case .requests:
            requestsButton.set(color: Asset.brandPrimary.color)
        case .scan:
            scanButton.set(color: Asset.brandPrimary.color)
        case .settings:
            settingsButton.set(color: Asset.brandPrimary.color)
        case .profile, .dashboard, .join:
            break
        }
    }

    private func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(20)
            $0.left.equalToSuperview().offset(30)
            $0.right.equalToSuperview().offset(-24)
        }

        stackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(26)
            $0.top.equalTo(headerView.snp.bottom).offset(75)
        }

        infoStackView.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.left.equalToSuperview().offset(20)
        }
    }
}
