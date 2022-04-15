import UIKit
import Shared

final class BackupConfigView: UIView {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let actionView = BackupActionView()

    let stackView = UIStackView()
    let iCloudButton = BackupSwitcherButton()
    let dropboxButton = BackupSwitcherButton()
    let googleDriveButton = BackupSwitcherButton()

    let enabledSubtitleView = UIView()
    let enabledSubtitleLabel = UILabel()
    let frequencyDetailView = BackupDetailView()
    let latestBackupDetailView = BackupDetailView()
    let infrastructureDetailView = BackupDetailView()

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralWhite.color

        titleLabel.textColor = Asset.neutralDark.color
        titleLabel.text = Localized.Backup.Config.title
        titleLabel.font = Fonts.Mulish.bold.font(size: 24.0)

        enabledSubtitleLabel.numberOfLines = 0
        enabledSubtitleLabel.textColor = Asset.neutralWeak.color
        enabledSubtitleLabel.font = Fonts.Mulish.regular.font(size: 14.0)

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineHeightMultiple = 1.15

        let attString = NSAttributedString(
            string: Localized.Backup.subtitle,
            attributes: [
                .foregroundColor: Asset.neutralBody.color,
                .font: Fonts.Mulish.regular.font(size: 16.0) as Any,
                .paragraphStyle: paragraph
            ])

        subtitleLabel.numberOfLines = 0
        subtitleLabel.attributedText = attString

        iCloudButton.titleLabel.text = Localized.Backup.iCloud
        iCloudButton.logoImageView.image = Asset.restoreIcloud.image

        dropboxButton.titleLabel.text = Localized.Backup.dropbox
        dropboxButton.logoImageView.image = Asset.restoreDropbox.image

        googleDriveButton.titleLabel.text = Localized.Backup.googleDrive
        googleDriveButton.logoImageView.image = Asset.restoreDrive.image

        latestBackupDetailView.titleLabel.text = Localized.Backup.Config.latestBackup
        frequencyDetailView.accessoryImageView.image = Asset.settingsDisclosure.image

        infrastructureDetailView.titleLabel.text = Localized.Backup.Config.infrastructure.uppercased()
        infrastructureDetailView.accessoryImageView.image = Asset.settingsDisclosure.image

        enabledSubtitleView.addSubview(enabledSubtitleLabel)

        stackView.axis = .vertical
        stackView.addArrangedSubview(googleDriveButton)
        stackView.addArrangedSubview(iCloudButton)
        stackView.addArrangedSubview(dropboxButton)
        stackView.addArrangedSubview(enabledSubtitleView)
        stackView.addArrangedSubview(latestBackupDetailView)
        stackView.addArrangedSubview(frequencyDetailView)
        stackView.addArrangedSubview(infrastructureDetailView)

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(actionView)
        addSubview(stackView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(38)
            make.right.equalToSuperview().offset(-41)
        }

        enabledSubtitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(92)
            make.right.equalToSuperview().offset(-48)
            make.bottom.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(38)
            make.right.equalToSuperview().offset(-41)
        }

        actionView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(38)
            make.right.equalToSuperview().offset(-38)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(actionView.snp.bottom).offset(28)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }
}
