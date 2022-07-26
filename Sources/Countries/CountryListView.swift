import UIKit
import Shared

final class CountryListView: UIView {
    let searchComponent = SearchComponent()

    lazy var collectionView: UICollectionView = {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .clear
        config.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 20, left: 0, bottom: 0, right: 0)
        return collectionView
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = Asset.neutralWhite.color

        searchComponent.set(
            imageAtRight: UIImage.color(.clear),
            inputAccessibility: Localized.Accessibility.Countries.Search.field,
            rightAccessibility: Localized.Accessibility.Countries.Search.right
        )

        addSubview(collectionView)
        addSubview(searchComponent)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    private func setupConstraints() {
        searchComponent.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchComponent.snp.bottom).offset(20)
            $0.left.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.right.equalToSuperview()
        }
    }
}
