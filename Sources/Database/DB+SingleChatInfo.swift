import GRDB
import Models

extension SingleChatInfo: Requestable {
    public static func query(_ request: Request) -> QueryInterfaceRequest<SingleChatInfo> {
        let lastMessageRequest = Message
            .annotated(with: max(Message.Column.timestamp))
            .group(Message.Column.sender || Message.Column.receiver)

        let lastMessageCTE = CommonTableExpression<Message>(
            named: "lastMessage",
            request: lastMessageRequest
        )

        let lastMessage = Contact.association(to: lastMessageCTE) { contact, lastMessage in
            lastMessage[Message.Column.sender] == contact[Contact.Column.userId] ||
            lastMessage[Message.Column.receiver] == contact[Contact.Column.userId]
        }.order(Message.Column.timestamp.desc)

        switch request {
        case .all:
            return Contact.with(lastMessageCTE)
                .including(required: lastMessage)
                .asRequest(of: Self.self)
        }
    }
}
