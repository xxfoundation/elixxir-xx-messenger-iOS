import Models
import Foundation
import DifferenceKit

struct ChatItem: Equatable, Differentiable {
    let date: Date
    var uniqueId: Data?
    let identity: Int64
    var roundURL: String?
    let payload: Payload
    var status: Message.Status
    var differenceIdentifier: Int64 { identity }

    init(_ message: Message) {
        self.identity = message.id!
        self.status = message.status
        self.payload = message.payload
        self.roundURL = message.roundURL
        self.uniqueId = message.uniqueId
        self.date = Date.fromTimestamp(message.timestamp)
    }
}

struct GroupChatItem: Equatable, Differentiable {
    let date: Date
    let sender: Data
    let identity: Int64
    var uniqueId: Data?
    var roundURL: String?
    let payload: Payload
    var status: GroupMessage.Status
    var differenceIdentifier: Int64 { identity }

    init(_ groupMessage: GroupMessage) {
        self.identity = groupMessage.id!
        self.status = groupMessage.status
        self.roundURL = groupMessage.roundURL
        self.sender = groupMessage.sender
        self.payload = groupMessage.payload
        self.uniqueId = groupMessage.uniqueId
        self.date = Date.fromTimestamp(groupMessage.timestamp)
    }
}
