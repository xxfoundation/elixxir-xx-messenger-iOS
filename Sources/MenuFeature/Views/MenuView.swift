import UIKit
import Shared
import AppResources

final class MenuView: UIView {
  let buildLabel = UILabel()
  let versionLabel = UILabel()
  let stackView = UIStackView()
  let xxdkVersionLabel = UILabel()
  let infoStackView = UIStackView()
  let headerView = MenuHeaderView()
  let joinButton = MenuSectionButton()
  let scanButton = MenuSectionButton()
  let shareButton = MenuSectionButton()
  let chatsButton = MenuSectionButton()
  let contactsButton = MenuSectionButton()
  let requestsButton = MenuSectionButton()
  let settingsButton = MenuSectionButton()
  let dashboardButton = MenuSectionButton()

  init() {
    super.init(frame: .zero)
    backgroundColor = Asset.neutralDark.color

    scanButton.set(title: Localized.Menu.scan, image: Asset.menuScan.image)
    shareButton.set(title: Localized.Menu.share, image: Asset.menuShare.image)
    chatsButton.set(title: Localized.Menu.chats, image: Asset.menuChats.image)
    joinButton.set(title: Localized.Menu.join, image: Asset.permissionLogo.image)
    requestsButton.set(title: Localized.Menu.requests, image: Asset.menuRequests.image)
    contactsButton.set(title: Localized.Menu.contacts, image: Asset.menuContacts.image)
    settingsButton.set(title: Localized.Menu.settings, image: Asset.menuSettings.image)
    dashboardButton.set(title: Localized.Menu.dashboard, image: Asset.menuDashboard.image)

    stackView.addArrangedSubview(chatsButton)
    stackView.addArrangedSubview(contactsButton)
    stackView.addArrangedSubview(requestsButton)
    stackView.addArrangedSubview(scanButton)
    stackView.addArrangedSubview(settingsButton)
    stackView.addArrangedSubview(dashboardButton)
    stackView.addArrangedSubview(joinButton)
    stackView.addArrangedSubview(shareButton)

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
