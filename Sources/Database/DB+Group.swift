import GRDB
import Models

extension Group: Persistable {
    static let members = hasMany(GroupMember.self)

    public enum Column: String, ColumnExpression {
        case id
        case name
        case leader
        case groupId
        case status
        case serialize
        case createdAt
        case accepted // Deprecated
    }

    public mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }

    public static func query(_ request: Request) -> QueryInterfaceRequest<Group> {
        switch request {
        case .withGroupId(let id):
            return Group.filter(Column.groupId == id)
        case .accepted:
            return Group.filter(Column.status == Group.Status.participating.rawValue)
        case .pending:
            return Group.filter(
                Column.status == Group.Status.pending.rawValue ||
                Column.status == Group.Status.hidden.rawValue
            )
        }
    }
}
