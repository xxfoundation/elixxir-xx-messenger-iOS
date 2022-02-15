import Foundation
import DifferenceKit

public struct GenericChatInfo: Codable, Equatable, Hashable {
    public var contact: Contact?
    public var groupInfo: GroupChatInfo?
    public var latestE2EMessage: Message?
    public var differenceIdentifier: Data { contact?.userId ?? groupInfo!.group.groupId }

    public init(
        contact: Contact?,
        groupInfo: GroupChatInfo?,
        latestE2EMessage: Message?
    ) {
        self.contact = contact
        self.groupInfo = groupInfo
        self.latestE2EMessage = latestE2EMessage
    }
}

extension GenericChatInfo: Differentiable {}
