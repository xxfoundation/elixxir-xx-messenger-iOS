import Foundation

public struct SingleChatInfo: Codable, Equatable, Hashable {
    public enum Request {
        case all
    }

    public var contact: Contact
    public var lastMessage: Message?

    public init(
        contact: Contact,
        lastMessage: Message?
    ) {
        self.contact = contact
        self.lastMessage = lastMessage
    }
}
