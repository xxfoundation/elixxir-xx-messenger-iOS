import UIKit
import Shared

final class ContactListEmptyView: UIView {
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    private(set) var searchButton = CapsuleButton()

    init() {
        super.init(frame: .zero)

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.2
        paragraph.alignment = .center

        titleLabel.attributedText = NSAttributedString(
            string: Localized.ContactList.Empty.title,
            attributes: [
                .paragraphStyle: paragraph,
                .foregroundColor: Asset.neutralActive.color,
                .font: Fonts.Mulish.bold.font(size: 24.0) as UIFont
            ]
        )

        titleLabel.numberOfLines = 0
        searchButton.setStyle(.brandColored)
        searchButton.setTitle(Localized.ContactList.Empty.action, for: .normal)

        stackView.spacing = 24
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(searchButton)

        addSubview(stackView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    private func setupConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
