import Models
import Foundation

public extension Contact {
    static let dummy = Contact(
        photo: nil,
        userId: Data(),
        email: nil,
        phone: nil,
        status: .friend,
        marshaled: Data(),
        username: "username",
        nickname: nil,
        createdAt: Date()
    )
}

public extension GroupChatInfo {
    static let dummy = GroupChatInfo(
        group: .dummy,
        members: []
    )
}

public extension Group {
    static let dummy = Group(
        leader: Data(),
        name: "name",
        groupId: Data(),
        accepted: true,
        serialize: Data()
    )
}

public extension SingleChatInfo {
    static let dummy = SingleChatInfo(contact: .dummy, lastMessage: nil)
}
