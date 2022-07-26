import Foundation

public struct DrawerListCellModel: Hashable {
    let id: Data
    let image: Data?
    let title: String
    let isCreator: Bool
    let isConnection: Bool

    public init(
        id: Data,
        title: String,
        image: Data? = nil,
        isCreator: Bool = false,
        isConnection: Bool = true
    ) {
        self.id = id
        self.title = title
        self.image = image
        self.isCreator = isCreator
        self.isConnection = isConnection
    }
}
