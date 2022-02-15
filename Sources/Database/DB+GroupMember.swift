import GRDB
import Models

extension GroupMember: Persistable {
    public enum Column: String, ColumnExpression {
        case id
        case photo
        case status
        case userId
        case groupId
        case username
    }

    public mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }

    public static func query(_ request: Request) -> QueryInterfaceRequest<GroupMember> {
        switch request {
        case let .withUserId(userId):
            return GroupMember.filter(Column.userId == userId)
        case .strangers:
            return GroupMember.filter(Column.status == GroupMember.Status.pendingUsername.rawValue)
        }
    }
}
