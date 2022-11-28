import Foundation

public struct Reply: Codable, Equatable, Hashable {
  public let messageId: Data
  public let senderId: Data

  public init(messageId: Data, senderId: Data) {
    self.messageId = messageId
    self.senderId = senderId
  }

  func asTextReply() -> TextReply {
    var reply = TextReply()
    reply.messageID = messageId
    reply.senderID = senderId

    return reply
  }
}
