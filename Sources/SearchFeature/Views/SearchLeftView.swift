import UIKit
import Shared

final class SearchLeftView: UIView {
    let inputStackView = UIStackView()
    let inputField = SearchComponent()
    let emptyView = SearchLeftEmptyView()
    let countryButton = SearchCountryComponent()
    let placeholderView = SearchLeftPlaceholderView()

    lazy var collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 10,
            bottom: 0,
            trailing: 10
        )

        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [sectionHeader]

        let layout = UICollectionViewCompositionalLayout(section: section)
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = Asset.neutralWhite.color
        return collectionView
    }()

    init() {
        super.init(frame: .zero)

        emptyView.isHidden = true
        backgroundColor = Asset.neutralWhite.color

        inputStackView.spacing = 5
        inputStackView.addArrangedSubview(countryButton)
        inputStackView.addArrangedSubview(inputField)

        addSubview(inputStackView)
        addSubview(collectionView)
        addSubview(emptyView)
        addSubview(placeholderView)

        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    func updateUIForItem(item: SearchSegmentedControl.Item) {
        countryButton.isHidden = item != .phone

        let emptyTitle = Localized.Ud.Search.empty(item.written)
        emptyView.titleLabel.text = emptyTitle

        let inputFieldTitle = Localized.Ud.Search.input(item.written)
        inputField.set(placeholder: inputFieldTitle, imageAtRight: nil)
    }

    private func setupConstraints() {
        inputStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(inputField.snp.bottom).offset(20)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        emptyView.snp.makeConstraints {
            $0.top.equalTo(inputField.snp.bottom).offset(20)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        placeholderView.snp.makeConstraints {
            $0.top.equalTo(inputField.snp.bottom)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
