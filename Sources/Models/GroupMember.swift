//import Foundation
//
//public struct GroupMember {
//    public enum Request {
//        case all
//        case strangers
//        case fromGroup(Data)
//        case withUserId(Data)
//    }
//
//    public enum Status: Int64, Codable {
//        case usernameSet
//        case pendingUsername
//    }
//
//    public var id: Int64?
//    public var userId: Data
//    public var groupId: Data
//    public var status: Status
//    public var username: String
//    public var photo: Data?
//
//    public init(
//        id: Int64? = nil,
//        userId: Data,
//        groupId: Data,
//        status: Status,
//        username: String,
//        photo: Data? = nil
//    ) {
//        self.id = id
//        self.userId = userId
//        self.groupId = groupId
//        self.username = username
//        self.status = status
//        self.photo = photo
//    }
//}
//
//extension GroupMember: Codable {}
//extension GroupMember: Hashable {}
//extension GroupMember: Equatable {}
