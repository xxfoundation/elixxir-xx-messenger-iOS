import UIKit
import Shared

final class SearchLeftSectionHeader: UICollectionReusableView {
    private let titleLabel = UILabel()

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.textColor = Asset.neutralWeak.color
        titleLabel.font = Fonts.Mulish.bold.font(size: 12.0)

        addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.left.equalToSuperview().offset(24)
            $0.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }

    func set(title: String) {
        titleLabel.text = title
    }
}
