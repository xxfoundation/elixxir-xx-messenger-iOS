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
        case .accepted:
            return Group
                .filter(Group.Column.accepted == true)
                .with(lastMessageCTE)
                .including(optional: lastMessage)
                .including(all: Group.members.forKey("members"))
                .asRequest(of: Self.self)
        }
    }
}
