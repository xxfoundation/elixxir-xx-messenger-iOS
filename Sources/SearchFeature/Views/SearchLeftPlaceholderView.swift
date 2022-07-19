import UIKit
import Shared
import Combine

final class SearchLeftPlaceholderView: UIView {
    let titleLabel = UILabel()
    let subtitleWithInfo = TextWithInfoView()

    var infoPublisher: AnyPublisher<Void, Never> {
        infoSubject.eraseToAnyPublisher()
    }

    private let infoSubject = PassthroughSubject<Void, Never>()

    init() {
        super.init(frame: .zero)

        let attrString = NSMutableAttributedString(
            string: Localized.Ud.Search.Username.Placeholder.title,
            attributes: [
                .foregroundColor: Asset.neutralDark.color,
                .font: Fonts.Mulish.bold.font(size: 32.0)
            ]
        )

        attrString.addAttribute(
            name: .foregroundColor,
            value: Asset.brandPrimary.color,
            betweenCharacters: "#"
        )

        titleLabel.numberOfLines = 0
        titleLabel.attributedText = attrString

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.3

        subtitleWithInfo.setup(
            text: Localized.Ud.Search.Username.Placeholder.subtitle,
            attributes: [
                .paragraphStyle: paragraph,
                .foregroundColor: Asset.neutralBody.color,
                .font: Fonts.Mulish.regular.font(size: 16.0)
            ],
            didTapInfo: { [weak self] in
                guard let self = self else { return }
                self.infoSubject.send(())
            }
        )

        addSubview(titleLabel)
        addSubview(subtitleWithInfo)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(50)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }

        subtitleWithInfo.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
