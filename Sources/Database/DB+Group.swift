import GRDB
import Models

extension Group: Persistable {
    static let members = hasMany(GroupMember.self)

    public enum Column: String, ColumnExpression {
        case id
        case name
        case leader
        case groupId
        case accepted
        case serialize
    }

    public mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }

    public static func query(_ request: Request) -> QueryInterfaceRequest<Group> {
        switch request {
        case .withGroupId(let id):
            return Group.filter(Column.groupId == id)
        case .accepted:
            return Group.filter(Column.accepted == true)
        case .pending:
            return Group.filter(Column.accepted == false)
        }
    }
}
