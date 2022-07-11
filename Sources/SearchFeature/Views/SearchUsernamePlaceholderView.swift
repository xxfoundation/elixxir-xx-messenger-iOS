import UIKit
import Shared

final class SearchUsernamePlaceholderView: UIView {
    let titleLabel = UILabel()

    init() {
        super.init(frame: .zero)

        titleLabel.text = "[SearchUsernamePlaceholderView]"

        addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }
}
