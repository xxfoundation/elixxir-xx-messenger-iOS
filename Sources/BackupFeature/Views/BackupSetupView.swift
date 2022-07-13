import UIKit
import Shared

final class BackupSetupView: UIView {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    let stackView = UIStackView()
    let sftpButton = BackupSwitcherButton()
    let iCloudButton = BackupSwitcherButton()
    let dropboxButton = BackupSwitcherButton()
    let googleDriveButton = BackupSwitcherButton()

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralWhite.color

        let title = Localized.Backup.Setup.title

        let attString = NSMutableAttributedString(string: title)
        let firstParagraph = NSMutableParagraphStyle()
        firstParagraph.alignment = .left
        firstParagraph.lineHeightMultiple = 1

        attString.addAttribute(.paragraphStyle, value: firstParagraph)
        attString.addAttribute(.foregroundColor, value: Asset.neutralActive.color)
        attString.addAttribute(.font, value: Fonts.Mulish.bold.font(size: 34.0) as Any)

        attString.addAttributes(attributes: [
            .font: Fonts.Mulish.bold.font(size: 34.0) as Any,
            .foregroundColor: Asset.brandPrimary.color
        ], betweenCharacters: "#")

        titleLabel.numberOfLines = 0
        titleLabel.attributedText = attString

        let secondParagraph = NSMutableParagraphStyle()
        secondParagraph.alignment = .left
        secondParagraph.lineHeightMultiple = 1.15

        let secondAttString = NSAttributedString(
            string: Localized.Backup.subtitle,
            attributes: [
                .foregroundColor: Asset.neutralBody.color,
                .font: Fonts.Mulish.regular.font(size: 16.0) as Any,
                .paragraphStyle: secondParagraph
            ])

        subtitleLabel.numberOfLines = 0
        subtitleLabel.attributedText = secondAttString

        iCloudButton.titleLabel.text = Localized.Backup.iCloud
        iCloudButton.logoImageView.image = Asset.restoreIcloud.image
        iCloudButton.showChevron()

        dropboxButton.titleLabel.text = Localized.Backup.dropbox
        dropboxButton.logoImageView.image = Asset.restoreDropbox.image
        dropboxButton.showChevron()

        googleDriveButton.titleLabel.text = Localized.Backup.googleDrive
        googleDriveButton.logoImageView.image = Asset.restoreDrive.image
        googleDriveButton.showChevron()

        sftpButton.titleLabel.text = Localized.Backup.sftp
        sftpButton.logoImageView.image = Asset.restoreSFTP.image
        sftpButton.showChevron()

        stackView.axis = .vertical
        stackView.addArrangedSubview(googleDriveButton)
        stackView.addArrangedSubview(iCloudButton)
        stackView.addArrangedSubview(dropboxButton)
        stackView.addArrangedSubview(sftpButton)

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(stackView)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.left.equalToSuperview().offset(38)
            $0.right.equalToSuperview().offset(-41)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(38)
            $0.right.equalToSuperview().offset(-41)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(28)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }
}
