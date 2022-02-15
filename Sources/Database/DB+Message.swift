import GRDB
import Models

extension Message: Persistable {
    public enum Column: String, ColumnExpression {
        case id
        case report
        case sender
        case unread
        case status
        case payload
        case roundURL
        case receiver
        case uniqueId
        case timestamp
    }

    public mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }

    public static func query(_ request: Request) -> QueryInterfaceRequest<Message> {
        switch request {
        case let .withUniqueId(id):
            return Message.filter(Column.uniqueId == id)
        case let .unreadsFromContactId(id):
            return Message
                .filter(Column.sender == id || Column.receiver == id)
                .filter(Column.unread == true)

        case let .latestOnesFromContactIds(ids):
            return Message
                .annotated(with: Column.timestamp)
                .filter(ids.contains(Column.sender) || ids.contains(Column.receiver))

        case let .withId(id):
            return Message.filter(Column.id == id)
        case let .withContact(id):
            return Message.filter(Column.sender == id || Column.receiver == id)
        case .sending:
            return Message.filter(Column.status == Message.Status.sending.rawValue)
        case .sendingAttachment:
            return Message.filter(Column.status == Message.Status.sendingAttachment.rawValue)
        }
    }
}
