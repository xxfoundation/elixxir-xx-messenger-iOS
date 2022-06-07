import Models
import Foundation
import DifferenceKit

enum Chat: Equatable, Differentiable, Hashable {
    case group(GroupChatInfo)
    case contact(SingleChatInfo)

    var differenceIdentifier: Data {
        switch self {
        case .contact(let info):
            return info.contact.userId
        case .group(let info):
            return info.group.groupId
        }
    }

    var orderingDate: Date {
        switch self {
        case .group(let info):
            if let lastMessage = info.lastMessage {
                return Date.fromTimestamp(lastMessage.timestamp)
            } else {
                return info.group.createdAt
            }
        case .contact(let info):
            guard let lastMessage = info.lastMessage else {
                fatalError("Should have an E2E chat without a last message")
            }

            return Date.fromTimestamp(lastMessage.timestamp)
        }
    }
}
