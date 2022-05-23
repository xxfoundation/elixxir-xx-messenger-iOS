import UIKit
import Shared

final class RequestReceivedEmptyCell: UICollectionViewCell {
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.textAlignment = .center
        titleLabel.textColor = Asset.neutralWeak.color
        titleLabel.font = Fonts.Mulish.regular.font(size: 14.0)
        titleLabel.text = Localized.Requests.Received.placeholder

        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(50)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-50)
        }
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    func setup(title: String) {
        titleLabel.text = title
    }
}
