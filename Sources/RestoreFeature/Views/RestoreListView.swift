import UIKit
import Shared

final class RestoreListView: UIView {
    let titleLabel = UILabel()
    let stackView = UIStackView()
    let firstSubtitleLabel = UILabel()
    let secondSubtitleLabel = UILabel()
    let driveButton = RowButton()
    let icloudButton = RowButton()
    let dropboxButton = RowButton()
    let cancelButton = CapsuleButton()

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralWhite.color

        setupTitle(Localized.AccountRestore.List.title)
        setupSubtitle(Localized.AccountRestore.List.firstSubtitle)

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineHeightMultiple = 1.15

        let attrString = NSMutableAttributedString(
            string: Localized.AccountRestore.List.secondSubtitle,
            attributes: [
                .foregroundColor: Asset.neutralBody.color,
                .font: Fonts.Mulish.regular.font(size: 16.0) as Any,
                .paragraphStyle: paragraph
            ]
        )

        secondSubtitleLabel.numberOfLines = 0
        secondSubtitleLabel.attributedText = attrString

        icloudButton.setup(title: Localized.Backup.iCloud, icon: Asset.restoreIcloud.image)
        dropboxButton.setup(title: Localized.Backup.dropbox, icon: Asset.restoreDropbox.image)
        driveButton.setup(title: Localized.Backup.googleDrive, icon: Asset.restoreDrive.image)

        cancelButton.set(style: .seeThrough, title: Localized.AccountRestore.List.cancel)

        stackView.axis = .vertical
        stackView.addArrangedSubview(driveButton)
        stackView.addArrangedSubview(icloudButton)
        stackView.addArrangedSubview(dropboxButton)

        addSubview(titleLabel)
        addSubview(firstSubtitleLabel)
        addSubview(secondSubtitleLabel)
        addSubview(stackView)
        addSubview(cancelButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(15)
            make.left.equalToSuperview().offset(38)
            make.right.equalToSuperview().offset(-41)
        }

        firstSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(38)
            make.right.equalToSuperview().offset(-41)
        }

        secondSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(firstSubtitleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(38)
            make.right.equalToSuperview().offset(-41)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(secondSubtitleLabel.snp.bottom).offset(28)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(stackView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-50)
        }
    }

    required init?(coder: NSCoder) { nil }

    private func setupTitle(_ title: String) {
        let attString = NSMutableAttributedString(string: title)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineHeightMultiple = 1

        attString.addAttribute(.paragraphStyle, value: paragraph)
        attString.addAttribute(.foregroundColor, value: Asset.neutralActive.color)
        attString.addAttribute(.font, value: Fonts.Mulish.bold.font(size: 34.0) as Any)

        attString.addAttributes(attributes: [
            .font: Fonts.Mulish.bold.font(size: 34.0) as Any,
            .foregroundColor: Asset.brandPrimary.color
        ], betweenCharacters: "#")

        titleLabel.numberOfLines = 0
        titleLabel.attributedText = attString
    }

    private func setupSubtitle(_ subtitle: String) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineHeightMultiple = 1.15

        let attString = NSAttributedString(
            string: subtitle,
            attributes: [
                .foregroundColor: Asset.neutralBody.color,
                .font: Fonts.Mulish.regular.font(size: 16.0) as Any,
                .paragraphStyle: paragraph
            ])

        firstSubtitleLabel.numberOfLines = 0
        firstSubtitleLabel.attributedText = attString
    }
}
