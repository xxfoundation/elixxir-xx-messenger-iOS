//import Foundation
//
//public struct Payload: Codable, Equatable, Hashable {
//    public var text: String
//    public var reply: Reply?
//    public var attachment: Attachment?
//
//    public init(text: String, reply: Reply?, attachment: Attachment?) {
//        self.text = text
//        self.reply = reply
//        self.attachment = attachment
//    }
//
//    public init(with marshaled: Data) throws {
//        let proto = try CMIXText(serializedData: marshaled)
//
//        var reply: Reply?
//
//        if proto.hasReply {
//            reply = Reply(
//                messageId: proto.reply.messageID,
//                senderId: proto.reply.senderID
//            )
//        }
//
//        self.init(text: proto.text, reply: reply, attachment: nil)
//    }
//
//    public func asData() -> Data {
//        var protoModel = CMIXText()
//        protoModel.text = text
//
//        if let reply = reply {
//            protoModel.reply = reply.asTextReply()
//        }
//
//        return try! protoModel.serializedData()
//    }
//}
