import UIKit
import Shared

final class ContactListView: UIView {
    let newGroupButton = ItemButton()
    let requestsButton = ItemButton()
    let topStackView = UIStackView()
    let stackView = UIStackView()
    let emptyTitleLabel = UILabel()
    let searchButton = CapsuleButton()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        backgroundColor = Asset.neutralWhite.color

        requestsButton.separatorView.isHidden = true
        requestsButton.setup(title: "Requests", image: Asset.contactListRequests.image)
        newGroupButton.setup(title: Localized.ContactList.newGroup, image: Asset.contactListNewGroup.image)

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.2
        paragraph.alignment = .center

        emptyTitleLabel.attributedText = NSAttributedString(
            string: Localized.ContactList.Empty.title,
            attributes: [
                .paragraphStyle: paragraph,
                .foregroundColor: Asset.neutralActive.color,
                .font: Fonts.Mulish.bold.font(size: 24.0) as UIFont
            ]
        )
        emptyTitleLabel.numberOfLines = 0

        searchButton.setStyle(.brandColored)
        searchButton.setTitle(Localized.ContactList.Empty.action, for: .normal)

        stackView.spacing = 24
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(emptyTitleLabel)
        stackView.addArrangedSubview(searchButton)

        topStackView.axis = .vertical
        topStackView.addArrangedSubview(newGroupButton)
        topStackView.addArrangedSubview(requestsButton)

        addSubview(topStackView)
        addSubview(stackView)

        setupConstraints()
    }

    private func setupConstraints() {
        topStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }
    }
}
