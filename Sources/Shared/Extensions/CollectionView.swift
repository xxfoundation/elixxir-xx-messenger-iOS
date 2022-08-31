import UIKit
import ChatLayout
import DifferenceKit

extension UICollectionReusableView: ReusableView {}

public extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func registerSectionHeader<T: UICollectionReusableView>(_: T.Type) {
        register(
            T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: T.reuseIdentifier
        )
    }

    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }

        return cell
    }

    func dequeueSupplementaryView<T: UICollectionReusableView>(forIndexPath indexPath: IndexPath) -> T {
        dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                         withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    convenience init(on view: UIView, with layout: CollectionViewChatLayout) {
        self.init(frame: view.frame, collectionViewLayout: layout)
        view.addSubview(self)

        frame = view.bounds
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true

        alwaysBounceVertical = true
        isPrefetchingEnabled = false
        keyboardDismissMode = .interactive
        showsHorizontalScrollIndicator = false
        contentInsetAdjustmentBehavior = .always
        backgroundColor = Asset.neutralSecondary.color
        automaticallyAdjustsScrollIndicatorInsets = true
    }

    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        onInterruptedReload: (() -> Void)? = nil,
        completion: ((Bool) -> Void)? = nil,
        setData: (C) -> Void
    ) {
        if case .none = window, let data = stagedChangeset.last?.data {
            setData(data)
            if let onInterruptedReload = onInterruptedReload {
                onInterruptedReload()
            } else {
                reloadData()
            }
            completion?(false)
            return
        }

        let dispatchGroup: DispatchGroup? = completion != nil
            ? DispatchGroup()
            : nil
        let completionHandler: ((Bool) -> Void)? = completion != nil
            ? { _ in
                dispatchGroup!.leave()
            }
            : nil

        for changeset in stagedChangeset {
            if let interrupt = interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
                setData(data)
                if let onInterruptedReload = onInterruptedReload {
                    onInterruptedReload()
                } else {
                    reloadData()
                }
                completion?(false)
                return
            }

            performBatchUpdates({
                setData(changeset.data)
                dispatchGroup?.enter()

                if !changeset.sectionDeleted.isEmpty {
                    deleteSections(IndexSet(changeset.sectionDeleted))
                }

                if !changeset.sectionInserted.isEmpty {
                    insertSections(IndexSet(changeset.sectionInserted))
                }

                if !changeset.sectionUpdated.isEmpty {
                    reloadSections(IndexSet(changeset.sectionUpdated))
                }

                for (source, target) in changeset.sectionMoved {
                    moveSection(source, toSection: target)
                }

                if !changeset.elementDeleted.isEmpty {
                    deleteItems(at: changeset.elementDeleted.map {
                        IndexPath(item: $0.element, section: $0.section)
                    })
                }

                if !changeset.elementInserted.isEmpty {
                    insertItems(at: changeset.elementInserted.map {
                        IndexPath(item: $0.element, section: $0.section)
                    })
                }

                if !changeset.elementUpdated.isEmpty {
                    reloadItems(at: changeset.elementUpdated.map {
                        IndexPath(item: $0.element, section: $0.section)
                    })
                }

                for (source, target) in changeset.elementMoved {
                    moveItem(at: IndexPath(item: source.element, section: source.section), to: IndexPath(item: target.element, section: target.section))
                }
            }, completion: completionHandler)
        }
        dispatchGroup?.notify(queue: .main) {
            completion!(true)
        }
    }
}

public extension StagedChangeset {
    func flattenIfPossible() -> StagedChangeset {
        if count == 2,
           self[0].sectionChangeCount == 0,
           self[1].sectionChangeCount == 0,
           self[0].elementDeleted.count == self[0].elementChangeCount,
           self[1].elementInserted.count == self[1].elementChangeCount {
            return StagedChangeset(arrayLiteral: Changeset(data: self[1].data, elementDeleted: self[0].elementDeleted, elementInserted: self[1].elementInserted))
        }
        return self
    }
}
