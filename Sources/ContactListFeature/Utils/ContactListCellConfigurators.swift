import Shared
import XXModels
import CollectionView

extension CellFactory where Model == Contact {
    static let contactListCellFactory = CellFactory<Contact>(
        register: .init(
            register: { $0.register(AvatarCell.self) }
        ),
        build: .init(build: { contact, collectionView, indexPath in
            let cell: AvatarCell = collectionView.dequeueReusableCell(
                forIndexPath: indexPath
            )

            cell.set(
                image: contact.photo,
                h1Text: (contact.nickname ?? contact.username) ?? "",
                showSeparator: false
            )

            return cell
        })
    )

    static let createGroupHeroCellFactory = CellFactory<Contact>(
        register: .init(
            register: { $0.register(CreateGroupHeroCollectionCell.self) }
        ),
        build: .init(build: { contact, collectionView, indexPath in
            let name = (contact.nickname ?? contact.username) ?? ""

            let cell: CreateGroupHeroCollectionCell = collectionView.dequeueReusableCell(
                forIndexPath: indexPath
            )

            cell.setup(
                title: name,
                image: contact.photo,
                action: {
                    // viewModel?.didSelect(contact: contact)
                }
            )

            return cell
        })
    )

    static let createGroupListCellFactory = CellFactory<Contact>(
        register: .init(
            register: { $0.register(AvatarCell.self) }
        ),
        build: .init(build: { contact, collectionView, indexPath in
            let name = (contact.nickname ?? contact.username) ?? ""

            let cell: AvatarCell = collectionView.dequeueReusableCell(
                forIndexPath: indexPath
            )

            cell.set(
                image: contact.photo,
                h1Text: name
            )

            //if let selectedElements = self?.selectedElements, selectedElements.contains(contact) {
            //    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            //} else {
            //    collectionView.deselectItem(at: indexPath, animated: true)
            //}

            return cell
        })
    )
}
