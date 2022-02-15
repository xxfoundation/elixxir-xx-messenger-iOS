import UIKit
import Shared

final class ChatListView: UIView {
    let titleLabel = UILabel()
    let snackBar = SnackBar()
    let stackView = UIStackView()
    let contactsButton = CapsuleButton()
    let searchView = SearchComponent()

    var networkIssueVisibleConstraint: NSLayoutConstraint?
    var networkIssueInvisibleConstraint: NSLayoutConstraint?

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    func displayNetworkIssue(_ flag: Bool) {
        self.networkIssueInvisibleConstraint?.isActive = !flag
        self.networkIssueVisibleConstraint?.isActive = flag

        snackBar.alpha = flag ? 0 : 1

        UIView.animate(withDuration: 0.5) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
            self.snackBar.alpha = flag ? 1 : 0
        }
    }

    private func setup() {
        snackBar.alpha = 0.0
        backgroundColor = Asset.neutralWhite.color

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.2
        paragraph.alignment = .center

        titleLabel.numberOfLines = 0
        titleLabel.attributedText = NSAttributedString(
            string: Localized.ChatList.emptyTitle,
            attributes: [
                .paragraphStyle: paragraph,
                .foregroundColor: Asset.neutralActive.color,
                .font: Fonts.Mulish.bold.font(size: 24.0)
            ]
        )

        contactsButton.setStyle(.brandColored)
        contactsButton.setTitle(Localized.ChatList.action, for: .normal)

        searchView.update(placeholder: "Search chats")

        stackView.spacing = 24
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(contactsButton)

        addSubview(snackBar)
        addSubview(searchView)
        addSubview(stackView)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            snackBar.leftAnchor.constraint(equalTo: leftAnchor),
            snackBar.rightAnchor.constraint(equalTo: rightAnchor)
        ])

        networkIssueVisibleConstraint = snackBar.topAnchor.constraint(equalTo: topAnchor)
        networkIssueInvisibleConstraint = snackBar.bottomAnchor.constraint(equalTo: topAnchor)

        networkIssueInvisibleConstraint?.isActive = true
        snackBar.translatesAutoresizingMaskIntoConstraints = false

        searchView.snp.makeConstraints { make in
            make.top.equalTo(snackBar.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }
    }
}
