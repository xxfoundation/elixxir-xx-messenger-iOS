import UIKit
import XXModels

final class IndexedContactList: UICollectionViewDiffableDataSource<Int, Contact> {
    private var indexTitles: [String] = []

    func set(indexTitles: [String]) {
        self.indexTitles = indexTitles
    }

    override func indexTitles(for collectionView: UICollectionView) -> [String]? {
        indexTitles
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        indexPathForIndexTitle title: String,
        at index: Int
    ) -> IndexPath {
        guard let index = indexTitles.firstIndex(where: { $0 == title }) else {
            return IndexPath(item: 0, section: 0)
        }

        return IndexPath(item: index, section: 0)
    }
}
