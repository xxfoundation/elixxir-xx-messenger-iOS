import UIKit
import Shared

final class SettingsView: UIView {
    enum InfoTapped {
        case dummyTraffic
        case biometrics
        case notifications
        case icognitoKeyboard
    }

    let generalStack = UIStackView()
    let generalTitle = UILabel()
    let biometrics = SettingsInfoSwitcher()
    let remoteNotifications = SettingsInfoSwitcher()
    let dummyTraffic = SettingsInfoSwitcher()
    let inAppNotifications = SettingsSwitcher()

    let chatStack = UIStackView()
    let chatTitle = UILabel()
    let hideActiveApp = SettingsSwitcher()
    let icognitoKeyboard = SettingsInfoSwitcher()

    let otherStack = UIStackView()
    let privacyPolicy = RowButton()
    let disclosures = RowButton()
    let advanced = RowButton()
    let delete = RowButton()

    let didTap: (InfoTapped) -> Void

    init(didTap: @escaping (InfoTapped) -> Void) {
        self.didTap = didTap

        super.init(frame: .zero)
        backgroundColor = Asset.neutralWhite.color

        setupGeneralStack()
        setupChatStack()
        setupOtherStack()
    }

    required init?(coder: NSCoder) { nil }

    private func setupGeneralStack() {
        generalTitle.text = Localized.Settings.general
        generalTitle.textColor = Asset.neutralActive.color
        generalTitle.font = Fonts.Mulish.semiBold.font(size: 18.0)

        remoteNotifications.set(
            title: Localized.Settings.RemoteNotifications.title,
            text: Localized.Settings.RemoteNotifications.description,
            icon: Asset.settingsNotifications.image
        ) { self.didTap(.notifications) }

        inAppNotifications.set(
            title: Localized.Settings.InAppNotifications.title,
            text: Localized.Settings.InAppNotifications.description,
            icon: Asset.settingsNotifications.image
        )

        dummyTraffic.set(
            title: Localized.Settings.Traffic.title,
            text: Localized.Settings.Traffic.subtitle,
            icon: Asset.settingsBiometrics.image,
            separator: false,
            didTapInfo: { self.didTap(.dummyTraffic) }
        )

        biometrics.set(
            title: Localized.Settings.Biometrics.title,
            text: Localized.Settings.Biometrics.description,
            icon: Asset.settingsBiometrics.image,
            separator: false
        ) { self.didTap(.biometrics) }

        generalStack.axis = .vertical
        generalStack.addArrangedSubview(remoteNotifications)
        generalStack.addArrangedSubview(dummyTraffic)
        generalStack.addArrangedSubview(inAppNotifications)
        generalStack.addArrangedSubview(biometrics)

        addSubview(generalTitle)
        addSubview(generalStack)

        generalTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(21)
        }

        generalStack.snp.makeConstraints { make in
            make.top.equalTo(generalTitle.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }

    private func setupChatStack() {
        chatTitle.text = Localized.Settings.chat
        chatTitle.textColor = Asset.neutralActive.color
        chatTitle.font = Fonts.Mulish.semiBold.font(size: 18.0)

        hideActiveApp.set(
            title: Localized.Settings.HideActiveApps.title,
            text: Localized.Settings.HideActiveApps.description,
            icon: Asset.settingsHide.image
        )

        icognitoKeyboard.set(
            title: Localized.Settings.IcognitoKeyboard.title,
            text: Localized.Settings.IcognitoKeyboard.description,
            icon: Asset.settingsKeyboard.image
        ) { self.didTap(.icognitoKeyboard) }

        chatStack.axis = .vertical
        chatStack.addArrangedSubview(hideActiveApp)
        chatStack.addArrangedSubview(icognitoKeyboard)

        addSubview(chatTitle)
        addSubview(chatStack)

        chatTitle.snp.makeConstraints { make in
            make.top.equalTo(generalStack.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(21)
        }

        chatStack.snp.makeConstraints { make in
            make.top.equalTo(chatTitle.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }

    private func setupOtherStack() {
        privacyPolicy.set(
            title: Localized.Settings.privacyPolicy,
            icon: Asset.settingsPrivacy.image,
            separator: false
        )

        disclosures.set(
            title: Localized.Settings.disclosures,
            icon: Asset.settingsFolder.image
        )

        advanced.set(
            title: Localized.Settings.advanced,
            icon: Asset.settingsAdvanced.image
        )

        delete.set(
            title: Localized.Settings.delete,
            icon: Asset.settingsDelete.image,
            style: .delete,
            separator: false
        )

        otherStack.axis = .vertical
        otherStack.addArrangedSubview(privacyPolicy)
        otherStack.addArrangedSubview(disclosures)
        otherStack.addArrangedSubview(advanced)
        otherStack.addArrangedSubview(delete)

        addSubview(otherStack)

        otherStack.snp.makeConstraints { make in
            make.top.equalTo(chatStack.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
    }
}
