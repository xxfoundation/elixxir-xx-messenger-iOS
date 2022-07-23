import UIKit
import Shared
import SnapKit

final class CreateGroupView: UIView {
    let stackView = UIStackView()
    let searchComponent = SearchComponent()
    lazy var topCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    lazy var bottomCollectionView: UICollectionView = {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = Asset.neutralWhite.color
        config.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 15, left: 0, bottom: 0, right: 0)
        return collectionView

        //tableView.setEditing(true, animated: true)
    }()

    let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 45
        layout.itemSize = CGSize(width: 56, height: 100)
        layout.scrollDirection = .horizontal
        return layout
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralWhite.color

        searchComponent.set(
            placeholder: "Search connections",
            imageAtRight: UIImage.color(.clear)
        )

        topCollectionView.backgroundColor = Asset.neutralWhite.color
        topCollectionView.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)

        stackView.spacing = 31
        stackView.axis = .vertical
        stackView.addArrangedSubview(topCollectionView)
        stackView.addArrangedSubview(bottomCollectionView)

        addSubview(stackView)
        addSubview(searchComponent)

        searchComponent.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(searchComponent.snp.bottom).offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        topCollectionView.snp.makeConstraints { $0.height.equalTo(100) }
    }

    required init?(coder: NSCoder) { nil }
}
