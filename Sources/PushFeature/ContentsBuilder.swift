import UserNotifications

public struct ContentsBuilder {
    enum Constants {
        static let threadIdentifier = "new_message_identifier"
    }

    public var build: (String, Push) -> UNMutableNotificationContent
}

public extension ContentsBuilder {
    static let live = ContentsBuilder { title, push in
        let content = UNMutableNotificationContent()
        content.badge = 1
        content.body = title
        content.title = title
        content.sound = .default
        content.userInfo["source"] = push.source
        content.userInfo["type"] = push.type.rawValue
        content.threadIdentifier = Constants.threadIdentifier
        return content
    }
}
