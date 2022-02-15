import Foundation

public struct Group: Codable, Equatable, Hashable {
    public enum Request {
        case pending
        case accepted
        case withGroupId(Data)
    }

    public var id: Int64?
    public var name: String
    public var leader: Data
    public var groupId: Data
    public var accepted: Bool
    public var serialize: Data
    public static var databaseTableName: String { "groups" }

    public init(
        leader: Data,
        name: String,
        groupId: Data,
        accepted: Bool,
        serialize: Data
    ) {
        self.name = name
        self.leader = leader
        self.groupId = groupId
        self.accepted = accepted
        self.serialize = serialize
    }
}
