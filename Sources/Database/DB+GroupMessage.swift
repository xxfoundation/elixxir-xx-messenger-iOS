import GRDB
import Models

extension GroupMessage: Persistable {
    public enum Column: String, ColumnExpression {
        case id
        case sender
        case status
        case unread
        case payload
        case groupId
        case uniqueId
        case roundURL
        case timestamp
        case roundId
    }

    public mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }

    public static func query(_ request: Request) -> QueryInterfaceRequest<GroupMessage> {
        switch request {
        case let .withUniqueId(id):
            return GroupMessage.filter(Column.uniqueId == id)
        case let .id(id):
            return GroupMessage.filter(Column.id == id)
        case let .fromGroup(id):
            return GroupMessage.filter(Column.groupId == id).order(Column.timestamp.asc)
        case let .unreadsFromGroup(id):
            return GroupMessage.filter(Column.groupId == id).filter(Column.unread == true)
        case .sending:
            return GroupMessage.filter(Column.status == GroupMessage.Status.sending.rawValue)
        }
    }
}
