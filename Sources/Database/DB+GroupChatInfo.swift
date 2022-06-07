import GRDB
import Models

extension GroupChatInfo: Requestable  {
    public static func query(_ request: Request) -> QueryInterfaceRequest<GroupChatInfo> {
        let lastMessageRequest = GroupMessage
            .annotated(with: max(GroupMessage.Column.timestamp))
            .group(GroupMessage.Column.groupId)

        let lastMessageCTE = CommonTableExpression<GroupMessage>(
            named: "lastMessage",
            request: lastMessageRequest
        )

        let lastMessage = Group.association(to: lastMessageCTE) { group, lastMessage in
            lastMessage[GroupMessage.Column.groupId] == group[Group.Column.groupId]
        }.order(GroupMessage.Column.timestamp.desc)

        switch request {
        case .fromGroup(let groupId):
            return Group
                .filter(Group.Column.status == Group.Status.participating.rawValue)
                .filter(Group.Column.groupId == groupId)
                .with(lastMessageCTE)
                .including(optional: lastMessage)
                .including(all: Group.members.forKey("members"))
                .asRequest(of: Self.self)

        case .accepted:
            return Group
                .filter(Group.Column.status == Group.Status.participating.rawValue)
                .with(lastMessageCTE)
                .including(optional: lastMessage)
                .including(all: Group.members.forKey("members"))
                .asRequest(of: Self.self)
        }
    }
}
