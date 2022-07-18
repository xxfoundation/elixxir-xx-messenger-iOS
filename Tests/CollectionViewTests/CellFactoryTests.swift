import XCTest
@testable import CollectionView

final class CellFactoryTests: XCTestCase {
  func testCombined() {
    var didRegisterFirst = [UICollectionView]()
    var didRegisterSecond = [UICollectionView]()
    var didRegisterThird = [UICollectionView]()

    class Cell: UICollectionViewCell {
      var collectionView: UICollectionView?
      var indexPath: IndexPath?
    }

    let factory = CellFactory<Int>.combined(
      .init(
        register: .init { didRegisterFirst.append($0) },
        build: .init { model, collectionView, indexPath in
          guard model == 1 else { return nil }
          let cell = Cell()
          cell.collectionView = collectionView
          cell.indexPath = indexPath
          return cell
        }
      ),
      .init(
        register: .init { didRegisterSecond.append($0) },
        build: .init { model, collectionView, indexPath in
          guard model == 2 else { return nil }
          let cell = Cell()
          cell.collectionView = collectionView
          cell.indexPath = indexPath
          return cell
        }
      ),
      .init(
        register: .init { didRegisterThird.append($0) },
        build: .init { model, collectionView, indexPath in
          guard model == 3 else { return nil }
          let cell = Cell()
          cell.collectionView = collectionView
          cell.indexPath = indexPath
          return cell
        }
      )
    )

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

    factory.register(in: collectionView)

    XCTAssertEqual(didRegisterFirst, [collectionView])
    XCTAssertEqual(didRegisterSecond, [collectionView])
    XCTAssertEqual(didRegisterThird, [collectionView])

    let firstCell = factory.build(for: 1, in: collectionView, at: IndexPath(item: 0, section: 1)) as? Cell

    XCTAssertEqual(firstCell?.collectionView, collectionView)
    XCTAssertEqual(firstCell?.indexPath, IndexPath(item: 0, section: 1))

    let secondCell = factory.build(for: 2, in: collectionView, at: IndexPath(item: 2, section: 3)) as? Cell

    XCTAssertEqual(secondCell?.collectionView, collectionView)
    XCTAssertEqual(secondCell?.indexPath, IndexPath(item: 2, section: 3))

    let thirdCell = factory.build(for: 3, in: collectionView, at: IndexPath(item: 4, section: 5)) as? Cell

    XCTAssertEqual(thirdCell?.collectionView, collectionView)
    XCTAssertEqual(thirdCell?.indexPath, IndexPath(item: 4, section: 5))

    let otherCell = factory.build(for: 4, in: collectionView, at: IndexPath(item: 0, section: 0))

    XCTAssertNil(otherCell)
  }
}
