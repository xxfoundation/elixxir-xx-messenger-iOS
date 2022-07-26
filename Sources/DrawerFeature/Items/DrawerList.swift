import UIKit
import Shared
import SnapKit

public final class DrawerList: DrawerItem {
    private let view = UIView()
    private var heightConstraint: Constraint?
    private let collectionView = UICollectionView()
    private let dataSource: UICollectionViewDiffableDataSource<Int, DrawerListCellModel>

    public var spacingAfter: CGFloat? = 0

    public init(spacingAfter: CGFloat? = 10) {
        self.dataSource = .init(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, model in
                var subtitle: String?
                var subtitleColor = Asset.neutralSecondaryAlternative.color
                let cell: DrawerListCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                if model.isCreator {
                    subtitle = "Creator"
                    subtitleColor = Asset.accentSafe.color
                } else if !model.isConnection {
                    subtitle = "Not a connection"
                }

                cell.set(
                    image: model.image,
                    title: model.title,
                    subtitle: subtitle,
                    subtitleColor: subtitleColor
                )

                return cell
            })

        self.spacingAfter = spacingAfter
    }

    public func makeView() -> UIView {
        collectionView.register(DrawerListCell.self)
        collectionView.dataSource = dataSource

        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            heightConstraint = $0.height.equalTo(1).priority(.low).constraint
        }

        return view
    }

    public func update(models: [DrawerListCellModel]) {
        let cellHeight = 56
        self.heightConstraint?.update(offset: cellHeight * models.count)

        var snapshot = NSDiffableDataSourceSnapshot<Int, DrawerListCellModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(models, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false) { [self] in
            let frameHeight = collectionView.frame.height
            let sizeHeight = collectionView.contentSize.height
            collectionView.isScrollEnabled =  sizeHeight > frameHeight
        }
    }
}
