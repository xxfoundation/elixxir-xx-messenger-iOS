import Foundation
import DifferenceKit

public struct Message: Codable, Equatable, Hashable {
    public enum Request {
        case sending
        case withUniqueId(Data)
        case withId(Int64)
        case sendingAttachment
        case withContact(Data)
        case unreadsFromContactId(Data)
        case latestOnesFromContactIds([Data])
    }

    public enum Status: Int64, Codable {
        case read
        case sent
        case sending
        case sendingAttachment
        case receivingAttachment
        case received
        case failedToSend
        case timedOut
    }

    public var id: Int64?
    public var unread: Bool
    public let sender: Data
    public var roundURL: String?
    public var report: Data?
    public var status: Status
    public let receiver: Data
    public var timestamp: Int
    public var uniqueId: Data?
    public var payload: Payload
    public static var databaseTableName: String { "messages" }

    public init (
        sender: Data,
        receiver: Data,
        payload: Payload,
        unread: Bool,
        timestamp: Int,
        uniqueId: Data?,
        status: Status,
        roundURL: String? = nil
    ) {
        self.sender = sender
        self.unread = unread
        self.status = status
        self.payload = payload
        self.receiver = receiver
        self.uniqueId = uniqueId
        self.timestamp = timestamp
        self.roundURL = roundURL
    }
}

public extension Message.Status {
    var canReply: Bool {
        switch self {
        case .sent, .received, .read:
            return true
        default:
            return false
        }
    }
}

extension Message: Differentiable {}
