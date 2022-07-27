import Shared
import XXModels
import CollectionView

extension CellFactory where Model == Contact {
    static func avatarCellFactory(showSeparator: Bool = true) -> Self {
        .init(
            register: .init { $0.register(AvatarCell.self) },
            build: .init { contact, collectionView, indexPath in
                let cell: AvatarCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                cell.set(
                    image: contact.photo,
                    h1Text: (contact.nickname ?? contact.username) ?? "",
                    showSeparator: showSeparator
                )

                return cell
            }
        )
    }

    static func createGroupHeroCellFactory(action: @escaping (Contact) -> Void) -> Self {
        .init(
            register: .init { $0.register(CreateGroupHeroCollectionCell.self) },
            build: .init { contact, collectionView, indexPath in
                let cell: CreateGroupHeroCollectionCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

                cell.setup(
                    title: (contact.nickname ?? contact.username) ?? "",
                    image: contact.photo,
                    action: { action(contact) }
                )

                return cell
            }
        )
    }
}
