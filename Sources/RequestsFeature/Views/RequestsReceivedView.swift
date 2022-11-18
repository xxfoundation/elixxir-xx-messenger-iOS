import UIKit
import Shared
import AppResources

final class RequestsReceivedView: UIView {
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
    
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 5
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
    
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
    collectionView.contentInset = .init(top: 15, left: 0, bottom: 0, right: 0)
    return collectionView
  }()
  
  init() {
    super.init(frame: .zero)
    addSubview(collectionView)
  }
  
  required init?(coder: NSCoder) { nil }
}

