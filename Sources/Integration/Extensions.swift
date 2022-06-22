import Models
import XXModels
import Bindings

extension Contact {
    init(with contact: BindingsContact, status: Contact.AuthStatus) {
        self.init(
            id: contact.getID()!,
            marshaled: try! contact.marshal(),
            username: contact.retrieve(fact: .username) ?? "",
            email: contact.retrieve(fact: .email),
            phone: contact.retrieve(fact: .phone),
            nickname: nil,
            photo: nil,
            authStatus: status,
            isRecent: false,
            createdAt: Date()
        )
    }
}

extension Message {
    init(with message: BindingsMessage, meMarshalled: Data) {
        guard let payload = try? Payload(with: message.getPayload()!) else { fatalError() }

        self.init(
            networkId: message.getID()!,
            senderId: message.getSender()!,
            recipientId: meMarshalled,
            groupId: nil,
            date: Date.fromTimestamp(Int(message.getTimestampNano())),
            status: .received,
            isUnread: true,
            text: payload.text,
            replyMessageId: payload.reply?.messageId,
            roundURL: message.getRoundURL(),
            fileTransferId: nil
        )
    }

    init(with message: BindingsGroupMessageReceive) {
        guard let payload = try? Payload(with: message.getPayload()!) else { fatalError() }

        self.init(
            networkId: message.getMessageID()!,
            senderId: message.getSenderID()!,
            recipientId: nil,
            groupId: message.getGroupID()!,
            date: Date.fromTimestamp(Int(message.getTimestampNano())),
            status: .received,
            isUnread: true,
            text: payload.text,
            replyMessageId: payload.reply?.messageId,
            roundURL: message.getRoundURL(),
            fileTransferId: nil
        )
    }
}
