import CustomDump
import XCTest
@testable import CollectionView

final class CellFactoryTests: XCTestCase {
  func testCombined() {
    struct Cell: Equatable {
      var model: Int
      var collectionView: UICollectionView
      var indexPath: IndexPath
    }

    var didRegisterFirst = [UICollectionView]()
    var didRegisterSecond = [UICollectionView]()
    var didRegisterThird = [UICollectionView]()

    var didBuildFirst = [Cell]()
    var didBuildSecond = [Cell]()
    var didBuildThird = [Cell]()

    let factory = CellFactory<Int>.combined(
      .init(
        register: .init { didRegisterFirst.append($0) },
        build: .init { model, collectionView, indexPath in
          guard model == 1 else { return nil }
          didBuildFirst.append(Cell(model: model, collectionView: collectionView, indexPath: indexPath))
          return UICollectionViewCell()
        }
      ),
      .init(
        register: .init { didRegisterSecond.append($0) },
        build: .init { model, collectionView, indexPath in
          guard model == 2 else { return nil }
          didBuildSecond.append(Cell(model: model, collectionView: collectionView, indexPath: indexPath))
          return UICollectionViewCell()
        }
      ),
      .init(
        register: .init { didRegisterThird.append($0) },
        build: .init { model, collectionView, indexPath in
          guard model == 3 else { return nil }
          didBuildThird.append(Cell(model: model, collectionView: collectionView, indexPath: indexPath))
          return UICollectionViewCell()
        }
      )
    )

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

    factory.register(in: collectionView)

    XCTAssertEqual(didRegisterFirst, [collectionView])
    XCTAssertEqual(didRegisterSecond, [collectionView])
    XCTAssertEqual(didRegisterThird, [collectionView])

    let firstCell = factory.build(for: 1, in: collectionView, at: IndexPath(item: 0, section: 1))

    XCTAssertNotNil(firstCell)
    XCTAssertNoDifference(didBuildFirst, [Cell(
      model: 1,
      collectionView: collectionView,
      indexPath: IndexPath(row: 0, section: 1)
    )])
    XCTAssertNoDifference(didBuildSecond, [])
    XCTAssertNoDifference(didBuildThird, [])

    didBuildFirst = []
    didBuildSecond = []
    didBuildThird = []
    let secondCell = factory.build(for: 2, in: collectionView, at: IndexPath(item: 2, section: 3))

    XCTAssertNotNil(secondCell)
    XCTAssertNoDifference(didBuildFirst, [])
    XCTAssertNoDifference(didBuildSecond, [Cell(
      model: 2,
      collectionView: collectionView,
      indexPath: IndexPath(row: 2, section: 3)
    )])
    XCTAssertNoDifference(didBuildThird, [])

    didBuildFirst = []
    didBuildSecond = []
    didBuildThird = []
    let thirdCell = factory.build(for: 3, in: collectionView, at: IndexPath(item: 4, section: 5))

    XCTAssertNotNil(thirdCell)
    XCTAssertNoDifference(didBuildFirst, [])
    XCTAssertNoDifference(didBuildSecond, [])
    XCTAssertNoDifference(didBuildThird, [Cell(
      model: 3,
      collectionView: collectionView,
      indexPath: IndexPath(row: 4, section: 5)
    )])

    didBuildFirst = []
    didBuildSecond = []
    didBuildThird = []
    let otherCell = factory.build(for: 4, in: collectionView, at: IndexPath(item: 0, section: 0))

    XCTAssertNil(otherCell)
    XCTAssertNoDifference(didBuildFirst, [])
    XCTAssertNoDifference(didBuildSecond, [])
    XCTAssertNoDifference(didBuildThird, [])
  }
}
