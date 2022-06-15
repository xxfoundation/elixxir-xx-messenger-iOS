//import Foundation
//import KeychainAccess
//
//public struct Group: Codable, Equatable, Hashable {
//    public enum Status: Int64, Codable {
//        case hidden
//        case pending
//        case deleting
//        case participating
//    }
//
//    public enum Request {
//        case pending
//        case accepted
//        case withGroupId(Data)
//    }
//
//    public var id: Int64?
//    public var name: String
//    public var leader: Data
//    public var groupId: Data
//    public var status: Status
//    public var serialize: Data
//    public var createdAt: Date
//    public static var databaseTableName: String { "groups" }
//
//    public init(
//        leader: Data,
//        name: String,
//        groupId: Data,
//        status: Status,
//        createdAt: Date,
//        serialize: Data
//    ) {
//        self.name = name
//        self.leader = leader
//        self.status = status
//        self.groupId = groupId
//        self.createdAt = createdAt
//        self.serialize = serialize
//    }
//}
