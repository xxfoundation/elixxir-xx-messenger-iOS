import UIKit
import Shared

final class SettingsAdvancedView: UIView {
    let stackView = UIStackView()
    let downloadLogsButton = UIButton()
    let logRecordingSwitcher = SettingsSwitcher()
    let crashReportingSwitcher = SettingsSwitcher()
    let showUsernamesSwitcher = SettingsSwitcher()

    init() {
        super.init(frame: .zero)

        backgroundColor = Asset.neutralWhite.color
        downloadLogsButton.setImage(Asset.settingsDownload.image, for: .normal)

        showUsernamesSwitcher.set(
            title: Localized.Settings.Advanced.ShowUsername.title,
            text: Localized.Settings.Advanced.ShowUsername.description,
            icon: Asset.settingsHide.image
        )

        logRecordingSwitcher.set(
            title: Localized.Settings.Advanced.Logs.title,
            text: Localized.Settings.Advanced.Logs.description,
            icon: Asset.settingsLogs.image,
            extraAction: downloadLogsButton
        )

        crashReportingSwitcher.set(
            title: Localized.Settings.Advanced.Crashes.title,
            text: Localized.Settings.Advanced.Crashes.description,
            icon: Asset.settingsCrash.image
        )

        stackView.axis = .vertical
        stackView.addArrangedSubview(logRecordingSwitcher)
        stackView.addArrangedSubview(crashReportingSwitcher)
        stackView.addArrangedSubview(showUsernamesSwitcher)

        stackView.setCustomSpacing(20, after: logRecordingSwitcher)
        stackView.setCustomSpacing(10, after: crashReportingSwitcher)
        stackView.setCustomSpacing(10, after: showUsernamesSwitcher)

        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }

    required init?(coder: NSCoder) { nil }
}
