import UIKit
import Shared

final class BackupActionView: UIView {
    let stackView = UIStackView()
    let backupNowButton = CapsuleButton()

    let progressView = UIView()
    let progressLabel = UILabel()
    let progressBarPartial = UIView()
    let progressBarFull = UIView()

    let finishedView = UIView()
    let finishedLabel = UILabel()
    let finishedImage = UIImageView()

    init() {
        super.init(frame: .zero)

        setupProgressView()
        setupFinishedView()

        backupNowButton.set(style: .brandColored, title: Localized.Backup.Config.backupNow)

        stackView.spacing = 15
        stackView.axis = .vertical
        stackView.addArrangedSubview(backupNowButton)
        stackView.addArrangedSubview(progressView)
        stackView.addArrangedSubview(finishedView)

        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    private func setupFinishedView() {
        finishedImage.contentMode = .center
        finishedImage.image = Asset.restoreSuccess.image

        finishedLabel.text = "Backup completed!"
        finishedLabel.textColor = Asset.neutralBody.color
        finishedLabel.font = Fonts.Mulish.regular.font(size: 16.0)

        finishedView.addSubview(finishedImage)
        finishedView.addSubview(finishedLabel)

        finishedImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        finishedLabel.snp.makeConstraints { make in
            make.left.equalTo(finishedImage.snp.right).offset(10)
            make.centerY.equalTo(finishedImage)
            make.right.lessThanOrEqualToSuperview()
        }
    }

    private func setupProgressView() {
        progressLabel.textColor = Asset.neutralDisabled.color
        progressLabel.font = Fonts.Mulish.regular.font(size: 14.0)

        progressBarFull.backgroundColor = Asset.neutralLine.color
        progressBarPartial.backgroundColor = Asset.brandPrimary.color
        progressBarFull.layer.masksToBounds = true
        progressBarFull.layer.cornerRadius = 4

        progressBarFull.addSubview(progressBarPartial)
        progressView.addSubview(progressLabel)
        progressView.addSubview(progressBarFull)

        progressBarFull.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(8)
        }

        progressLabel.snp.makeConstraints { make in
            make.top.equalTo(progressBarFull.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        progressBarPartial.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.bottom.equalToSuperview()
        }
    }

    func setState(_ state: BackupActionState) {
        switch state {
        case .backupFinished:
            backupNowButton.isHidden = true
            progressView.isHidden = true
            finishedView.isHidden = false

        case .backupAllowed(let bool):
            backupNowButton.isHidden = false
            progressView.isHidden = true
            finishedView.isHidden = true
            backupNowButton.isEnabled = bool

        case .backupInProgress(let uploaded, let total):
            backupNowButton.isHidden = true
            progressView.isHidden = false
            finishedView.isHidden = true

            let uploadedKb = String(format: "%.1f kb", uploaded/1000)
            let totalkb = String(format: "%.1f kb", total/1000)

            progressLabel.text = "Uploaded \(uploadedKb) of \(totalkb) (\(total/uploaded)%)"
        }
    }
}
