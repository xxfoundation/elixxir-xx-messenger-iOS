import UIKit
import Shared

final class RequestsSentView: UIView {
    let titleLabel = UILabel()
    let connectionsButton = CapsuleButton()

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
        titleLabel.text = Localized.Requests.Sent.empty
        titleLabel.textColor = Asset.neutralWeak.color
        titleLabel.font = Fonts.Mulish.regular.font(size: 14.0)

        connectionsButton.set(
            style: .brandColored,
            title: Localized.Requests.Sent.action
        )

        addSubview(titleLabel)
        addSubview(connectionsButton)
        addSubview(collectionView)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48.5)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
        }

        connectionsButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
        }

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { nil }
}
