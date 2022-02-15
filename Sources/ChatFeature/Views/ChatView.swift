import UIKit
import Shared

final class ChatView: UIView {
    let titleLabel = UILabel()
    let snackBar = SnackBar()

    var networkIssueVisibleConstraint: NSLayoutConstraint?
    var networkIssueInvisibleConstraint: NSLayoutConstraint?

    init() {
        super.init(frame: .zero)

        snackBar.alpha = 0.0
        backgroundColor = Asset.neutralSecondary.color

        addSubview(snackBar)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            snackBar.leftAnchor.constraint(equalTo: leftAnchor),
            snackBar.rightAnchor.constraint(equalTo: rightAnchor)
        ])

        networkIssueVisibleConstraint = snackBar.topAnchor.constraint(equalTo: topAnchor)
        networkIssueInvisibleConstraint = snackBar.bottomAnchor.constraint(equalTo: topAnchor)

        networkIssueInvisibleConstraint?.isActive = true
        snackBar.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(45)
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-61)
        }
    }

    required init?(coder: NSCoder) { nil }

    func displayNetworkIssue(_ flag: Bool) {
        networkIssueInvisibleConstraint?.isActive = !flag
        networkIssueVisibleConstraint?.isActive = flag

        snackBar.alpha = flag ? 0 : 1

        UIView.animate(withDuration: 0.5) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
            self.snackBar.alpha = flag ? 1 : 0
        }
    }

    func set(name: String) {
        titleLabel.numberOfLines = 0

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.15
        paragraph.alignment = .left

        let attrString = NSMutableAttributedString(
            string: Localized.Chat.E2e.placeholder(name)
        )

        attrString.addAttributes([
            .paragraphStyle: paragraph,
            .foregroundColor: Asset.neutralActive.color,
            .font: Fonts.Mulish.bold.font(size: 32.0) as Any
        ])

        attrString.addAttribute(
            name: .foregroundColor,
            value: Asset.brandPrimary.color,
            betweenCharacters: "#"
        )

        titleLabel.attributedText = attrString
    }
}
