import GRDB
import Models

extension Contact: Persistable {    
    public enum Column: String, ColumnExpression {
        case id
        case photo
        case email
        case phone
        case userId
        case status
        case username
        case isRecent
        case nickname
        case marshaled
        case createdAt
    }

    public mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    public static func query(_ request: Request) -> QueryInterfaceRequest<Contact> {
        switch request {
        case .all:
            return Contact.all()
        case .isRecent:
            return Contact
                .filter(Column.isRecent == true)
                .order(Column.createdAt.desc)
        case .verificationInProgress:
            return Contact.filter(Column.status == Contact.Status.verificationInProgress.rawValue)
        case .failed:
            return Contact.filter(
                Column.status == Contact.Status.requestFailed.rawValue ||
                Column.status == Contact.Status.confirmationFailed.rawValue
            )
        case .requested:
            return Contact.filter(
                Column.status == Contact.Status.requested.rawValue ||
                Column.status == Contact.Status.requesting.rawValue
            )
        case .received:
            return Contact.filter(
                Column.status == Contact.Status.hidden.rawValue ||
                Column.status == Contact.Status.verified.rawValue ||
                Column.status == Contact.Status.verificationFailed.rawValue ||
                Column.status == Contact.Status.verificationInProgress.rawValue
            )

        case .friends: return Contact.filter(Column.status == Contact.Status.friend.rawValue)
        case let .withUserId(data): return Contact.filter(Column.userId == data)
        case let .withUserIds(ids): return Contact.filter(ids.contains(Contact.Column.userId))
        case let .withUsername(username): return Contact.filter(Column.username.like("\(username)%"))
        }
    }
}
