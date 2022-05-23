import UIKit
import Shared

final class RequestsFailedView: UIView {
    let titleLabel = UILabel()

    lazy var collectionView: UICollectionView = {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = Asset.neutralWhite.color
        config.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 15, left: 0, bottom: 0, right: 0)
        return collectionView
    }()

    init() {
        super.init(frame: .zero)

        titleLabel.textAlignment = .center
        titleLabel.text = Localized.Requests.Failed.empty
        titleLabel.textColor = Asset.neutralWeak.color
        titleLabel.font = Fonts.Mulish.regular.font(size: 14.0)

        addSubview(titleLabel)
        addSubview(collectionView)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48.5)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }
}
