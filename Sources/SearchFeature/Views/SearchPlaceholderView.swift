import UIKit
import Shared

final class SearchPlaceholderView: UIView {
    let titleView = TextWithInfoView()
    let didTapInfo: () -> Void

    init(didTapInfo: @escaping () -> Void) {
        self.didTapInfo = didTapInfo

        super.init(frame: .zero)

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        paragraph.lineHeightMultiple = 1.0
        paragraph.alignment = .center

        titleView.setup(
            text: "Your searches are anonymous.\nSearch information is never linked to your account or personally identifiable.",
            attributes: [
                .foregroundColor: Asset.neutralBody.color,
                .font: Fonts.Mulish.regular.font(size: 16.0) as Any,
                .paragraphStyle: paragraph
            ],
            didTapInfo: { didTapInfo() }
        )

        addSubview(titleView)

        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(-60)
        }
    }

    required init?(coder: NSCoder) { nil }
}

final class SearchEmptyView: UIView {
    private let title = UILabel()

    init() {
        super.init(frame: .zero)

        backgroundColor = Asset.neutralWhite.color

        title.textColor = Asset.neutralBody.color
        title.font = Fonts.Mulish.regular.font(size: 12.0)

        addSubview(title)

        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
        }
    }

    required init?(coder: NSCoder) { nil }

    func set(filter: String) {
        title.text = Localized.Ud.noneFound(filter)
    }
}
