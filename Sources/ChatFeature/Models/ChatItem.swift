import Models
import XXModels
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
        self.payload = Payload(text: message.text, reply: nil)
        self.roundURL = message.roundURL
        self.uniqueId = message.networkId
        self.date = message.date
    }
}
