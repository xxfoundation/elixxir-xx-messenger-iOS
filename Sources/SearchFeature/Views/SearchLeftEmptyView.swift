import UIKit
import Shared

final class SearchLeftEmptyView: UIView {
    let titleLabel = UILabel()

    init() {
        super.init(frame: .zero)

        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = Fonts.Mulish.regular.font(size: 15.0)
        titleLabel.textColor = Asset.neutralSecondaryAlternative.color

        addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }
    }

    required init?(coder: NSCoder) { nil }
}
