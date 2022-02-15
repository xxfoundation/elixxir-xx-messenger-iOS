import Foundation

public struct GroupMessage: Codable, Equatable, Hashable {
    public enum Request {
        case withUniqueId(Data)
        case id(Int64)
        case sending
        case fromGroup(Data)
        case unreadsFromGroup(Data)
    }

    public static var databaseTableName: String { "groupMessages" }

    public enum Status: Int64, Codable {
        case sent
        case read
        case failed
        case sending
        case received
    }

    public var id: Int64?
    public var uniqueId: Data?
    public var groupId: Data
    public var sender: Data
    public var roundId: Int64?
    public var payload: Payload
    public var status: Status
    public var roundURL: String?
    public var unread: Bool
    public var timestamp: Int

    public init(
        id: Int64? = nil,
        sender: Data,
        groupId: Data,
        payload: Payload,
        unread: Bool,
        timestamp: Int = 0,
        uniqueId: Data?,
        status: Status,
        roundId: Int64? = nil,
        roundURL: String? = nil
    ) {
        self.id = id
        self.sender = sender
        self.groupId = groupId
        self.payload = payload
        self.unread = unread
        self.timestamp = timestamp
        self.uniqueId = uniqueId
        self.status = status
        self.roundId = roundId
        self.roundURL = roundURL
    }
}
