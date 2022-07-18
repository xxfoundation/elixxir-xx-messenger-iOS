import UIKit

public struct CellFactory<Model> {
  public struct Registrar {
    public var register: (UICollectionView) -> Void

    public func callAsFunction(in view: UICollectionView) {
      register(view)
    }
  }

  public struct Builder {
    public var buildCell: (Model, UICollectionView, IndexPath) -> UICollectionViewCell?

    public func callAsFunction(
      for model: Model,
      in view: UICollectionView,
      at indexPath: IndexPath
    ) -> UICollectionViewCell? {
      buildCell(model, view, indexPath)
    }
  }

  public var register: Registrar
  public var build: Builder

  public init(
    register: Registrar,
    build: Builder
  ) {
    self.register = register
    self.build = build
  }
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
        factories.lazy
          .compactMap { $0.build(for: model, in: collectionView, at: indexPath) }
          .first
      }
    )
  }
}

#if DEBUG
extension CellFactory {
  public static func failing() -> CellFactory {
    CellFactory(
      register: .init { _ in fatalError("Not implemented") },
      build: .init { _, _, _ in fatalError("Not implemented") }
    )
  }
}
#endif
