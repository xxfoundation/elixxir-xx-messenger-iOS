import UIKit
import Shared

final class AdvancedView: UIView {
    let stack = UIStackView()
    let downloadLogs = UIButton()
    let logs = SettingsSwitcher()
    let crashes = SettingsSwitcher()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        backgroundColor = Asset.neutralWhite.color
        downloadLogs.setImage(Asset.settingsDownload.image, for: .normal)

        logs.set(
            title: Localized.Settings.Advanced.Logs.title,
            text: Localized.Settings.Advanced.Logs.description,
            icon: Asset.settingsLogs.image,
            extraAction: downloadLogs
        )

        crashes.set(
            title: Localized.Settings.Advanced.Crashes.title,
            text: Localized.Settings.Advanced.Crashes.description,
            icon: Asset.settingsCrash.image,
            separator: false
        )

        stack.spacing = 20
        stack.axis = .vertical
        stack.addArrangedSubview(logs)
        stack.addArrangedSubview(crashes)

        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
}
