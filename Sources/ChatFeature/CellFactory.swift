import UIKit
import XCTestDynamicOverlay

public struct CellFactory<Model> {
  public struct Registrar {
    public init(register: @escaping (UICollectionView) -> Void) {
      self.register = register
    }

    public var register: (UICollectionView) -> Void

    public func callAsFunction(in view: UICollectionView) {
      register(view)
    }
  }

  public struct Builder {
    public init(build: @escaping (Model, UICollectionView, IndexPath) -> UICollectionViewCell?) {
      self.build = build
    }

    public var build: (Model, UICollectionView, IndexPath) -> UICollectionViewCell?

    public func callAsFunction(
      for model: Model,
      in view: UICollectionView,
      at indexPath: IndexPath
    ) -> UICollectionViewCell? {
      build(model, view, indexPath)
    }
  }

  public init(
    register: Registrar,
    build: Builder
  ) {
    self.register = register
    self.build = build
  }

  public var register: Registrar
  public var build: Builder
}

extension CellFactory {
  public static func combined(_ factories: CellFactory...) -> CellFactory {
    combined(factories)
  }

  public static func combined(_ factories: [CellFactory]) -> CellFactory {
    CellFactory(
      register: .init { collectionView in
        factories.forEach { $0.register(in: collectionView) }
      },
      build: .init { model, collectionView, indexPath in
        for factory in factories {
          if let cell = factory.build(for: model, in: collectionView, at: indexPath) {
            return cell
          }
        }
        return nil
      }
    )
  }
}

#if DEBUG
extension CellFactory {
  public static func unimplemented() -> CellFactory {
    CellFactory(
      register: .init(register: XCTUnimplemented("\(Self.self).Registrar")),
      build: .init(build: XCTUnimplemented("\(Self.self).Builder"))
    )
  }
}
#endif
