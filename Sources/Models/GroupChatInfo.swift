import Foundation

public struct GroupChatInfo: Codable, Equatable, Hashable {
    public enum Request {
        case accepted
    }

    public var group: Group
    public var members: [GroupMember]
    public var lastMessage: GroupMessage?

    public init(
        group: Group,
        members: [GroupMember],
        lastMessage: GroupMessage? = nil
    ) {
        self.group = group
        self.members = members
        self.lastMessage = lastMessage
    }
}
