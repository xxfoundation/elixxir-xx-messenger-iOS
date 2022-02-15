import GRDB
import Models

extension FileTransfer: Persistable {
    public enum Column: String, ColumnExpression {
        case id
        case tid
        case contact
        case fileName
        case fileType
        case isIncoming
    }

    public mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }

    public static func query(_ request: Request) -> QueryInterfaceRequest<FileTransfer> {
        switch request {
        case .withTID(let transferId):
            return FileTransfer.filter(Column.tid == transferId)
        case .withContactId(let contactId):
            return FileTransfer.filter(Column.contact == contactId)
        }
    }
}
