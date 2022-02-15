import Models
import Bindings

extension Contact {
    init(with contact: BindingsContact, status: Contact.Status) {
        self.init(
            photo: nil,
            userId: contact.getID()!,
            email: contact.retrieve(fact: .email),
            phone: contact.retrieve(fact: .phone),
            status: status,
            marshaled: try! contact.marshal(),
            username: contact.retrieve(fact: .username) ?? "",
            nickname: nil,
            createdAt: Date()
        )
    }
}

extension Message {
    init(with message: BindingsMessage, meMarshalled: Data) {
        guard let payload = try? Payload(with: message.getPayload()!) else { fatalError() }

        self.init(
            sender: message.getSender()!,
            receiver: meMarshalled,
            payload: payload,
            unread: true,
            timestamp: Int(message.getTimestampNano()),
            uniqueId: message.getID()!,
            status: .received,
            roundURL: message.getRoundURL()
        )
    }
}

extension GroupMessage {
    init(with message: BindingsGroupMessageReceive) {
        guard let payload = try? Payload(with: message.getPayload()!) else { fatalError() }

        self.init(
            sender: message.getSenderID()!,
            groupId: message.getGroupID()!,
            payload: payload,
            unread: true,
            timestamp: Int(message.getTimestampNano()),
            uniqueId: message.getMessageID()!,
            status: .received,
            roundURL: message.getRoundURL()
        )
    }
}
