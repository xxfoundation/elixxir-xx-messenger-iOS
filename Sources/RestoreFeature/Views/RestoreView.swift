import UIKit
import Shared
import Models

final class RestoreView: UIView {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let detailsView = RestoreDetailsView()
    let progressView = RestoreProgressView()

    let bottomStackView = UIStackView()
    let backButton = CapsuleButton()
    let cancelButton = CapsuleButton()
    let restoreButton = CapsuleButton()

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralWhite.color

        subtitleLabel.numberOfLines = 0
        titleLabel.font = Fonts.Mulish.bold.font(size: 24.0)
        subtitleLabel.font = Fonts.Mulish.regular.font(size: 16.0)
        titleLabel.textColor = Asset.neutralDark.color
        subtitleLabel.textColor = Asset.neutralDark.color

        restoreButton.set(style: .brandColored, title: Localized.AccountRestore.Found.restore)
        cancelButton.set(style: .simplestColoredBrand, title: Localized.AccountRestore.Found.cancel)
        backButton.set(style: .seeThrough, title: Localized.AccountRestore.NotFound.back)

        bottomStackView.axis = .vertical

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(detailsView)
        addSubview(progressView)
        addSubview(bottomStackView)

        bottomStackView.addArrangedSubview(restoreButton)
        bottomStackView.addArrangedSubview(cancelButton)
        bottomStackView.addArrangedSubview(backButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(20)
            $0.left.equalToSuperview().offset(38)
            $0.right.equalToSuperview().offset(-38)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(38)
            $0.right.equalToSuperview().offset(-38)
        }

        detailsView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }

        progressView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(detailsView.snp.bottom)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.lessThanOrEqualTo(bottomStackView.snp.top)
        }

        bottomStackView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(detailsView.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-40)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }
    }

    required init?(coder: NSCoder) { nil }

    func updateFor(step: RestorationStep) {
        switch step {
        case .idle(let cloudService, let backup):
            guard let backup = backup else {
                showNoBackupForCloud(named: cloudService.name())
                return
            }

            showBackup(backup, fromCloud: cloudService)

        case .downloading(let downloaded, let total):
            restoreButton.isHidden = true
            cancelButton.isHidden = true
            progressView.isHidden = false

            progressView.update(downloaded: downloaded, total: total)
        case .wrongPass:
            progressView.descriptiveProgressLabel.text = "Incorrect password"

        case .failDownload(let error):
            progressView.descriptiveProgressLabel.text = error.localizedDescription

        case .parsingData:
            progressView.descriptiveProgressLabel.text = "Parsing backup data"

        case .done:
            progressView.descriptiveProgressLabel.text = "Done"
        }
    }

    private func showBackup(_ backup: BackupModel, fromCloud cloud: CloudService) {
        titleLabel.text = Localized.AccountRestore.Found.title
        subtitleLabel.text = Localized.AccountRestore.Found.subtitle

        detailsView.titleLabel.text = cloud.name()
        detailsView.imageView.image = cloud.asset()

        detailsView.dateView.setup(
            title: Localized.AccountRestore.Found.date,
            value: backup.date.backupStyle(),
            hasArrow: false
        )

        detailsView.sizeView.setup(
            title: Localized.AccountRestore.Found.size,
            value: String(format: "%.1f kb", backup.size/1000),
            hasArrow: false
        )

        detailsView.isHidden = false
        backButton.isHidden = true
        restoreButton.isHidden = false
        cancelButton.isHidden = false
        progressView.isHidden = true
    }

    private func showNoBackupForCloud(named cloud: String) {
        titleLabel.text = Localized.AccountRestore.NotFound.title
        subtitleLabel.text = Localized.AccountRestore.NotFound.subtitle(cloud)

        restoreButton.isHidden = true
        cancelButton.isHidden = true
        detailsView.isHidden = true
        backButton.isHidden = false
        progressView.isHidden = true
    }
}

private extension CloudService {
    func name() -> String {
        switch self {
        case .drive:
            return Localized.Backup.googleDrive
        case .icloud:
            return Localized.Backup.iCloud
        case .dropbox:
            return Localized.Backup.dropbox
        case .sftp:
            return Localized.Backup.sftp
        }
    }

    func asset() -> UIImage {
        switch self {
        case .drive:
            return Asset.restoreDrive.image
        case .icloud:
            return Asset.restoreIcloud.image
        case .dropbox:
            return Asset.restoreDropbox.image
        case .sftp:
            return Asset.restoreSFTP.image
        }
    }
}
