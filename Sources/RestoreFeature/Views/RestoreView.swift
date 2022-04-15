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

        restoreButton.set(style: .brandColored, title: Localized.Restore.Found.restore)
        cancelButton.set(style: .simplestColoredBrand, title: Localized.Restore.Found.cancel)
        backButton.set(style: .seeThrough, title: Localized.Restore.NotFound.back)

        bottomStackView.axis = .vertical

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(detailsView)
        addSubview(progressView)
        addSubview(bottomStackView)

        bottomStackView.addArrangedSubview(restoreButton)
        bottomStackView.addArrangedSubview(cancelButton)
        bottomStackView.addArrangedSubview(backButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20)
            make.left.equalToSuperview().offset(38)
            make.right.equalToSuperview().offset(-38)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(38)
            make.right.equalToSuperview().offset(-38)
        }

        detailsView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        progressView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(detailsView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.lessThanOrEqualTo(bottomStackView.snp.top)
        }

        bottomStackView.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(detailsView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
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

        case .failDownload(let error):
            progressView.descriptiveProgressLabel.text = error.localizedDescription

        case .parsingData:
            progressView.descriptiveProgressLabel.text = "Parsing backup data"

        case .done:
            progressView.descriptiveProgressLabel.text = "Done"
        }
    }

    private func showBackup(_ backup: Backup, fromCloud cloud: CloudService) {
        titleLabel.text = Localized.Restore.Found.title
        subtitleLabel.text = Localized.Restore.Found.subtitle

        detailsView.titleLabel.text = cloud.name()
        detailsView.imageView.image = cloud.asset()

        detailsView.dateView.setup(
            title: Localized.Restore.Found.date,
            value: backup.date.backupStyle(),
            hasArrow: false
        )

        detailsView.sizeView.setup(
            title: Localized.Restore.Found.size,
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
        titleLabel.text = Localized.Restore.NotFound.title
        subtitleLabel.text = Localized.Restore.NotFound.subtitle(cloud)

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
        }
    }
}
