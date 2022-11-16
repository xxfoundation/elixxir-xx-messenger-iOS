import Foundation

public struct Payload: Codable, Equatable, Hashable {
  public var text: String
  public var reply: Reply?
  
  public init(text: String, reply: Reply?) {
    self.text = text
    self.reply = reply
  }
  
  public init(with marshaled: Data) throws {
    let proto = try CMIXText(serializedData: marshaled)
    
    var reply: Reply?
    
    if proto.hasReply {
      reply = Reply(
        messageId: proto.reply.messageID,
        senderId: proto.reply.senderID
      )
    }
    
    self.init(text: proto.text, reply: reply)
  }
  
  public func asData() -> Data {
    var protoModel = CMIXText()
    protoModel.text = text
    
    if let reply = reply {
      protoModel.reply = reply.asTextReply()
    }
    
    return try! protoModel.serializedData()
  }
}
