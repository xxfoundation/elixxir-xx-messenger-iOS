import Foundation

public struct Report: Encodable {
    public init(
        sender: ReportUser,
        recipient: ReportUser,
        type: ReportType,
        screenshot: Data
    ) {
        self.sender = sender
        self.recipient = recipient
        self.type = type
        self.screenshot = screenshot
    }

    public var sender: ReportUser
    public var recipient: ReportUser
    public var type: ReportType
    public var screenshot: Data
}

extension Report {
    public struct ReportUser: Encodable {
        public init(
            userId: String,
            username: String
        ) {
            self.userId = userId
            self.username = username
        }

        public var userId: String
        public var username: String
    }
}

extension Report {
    public enum ReportType: String, Encodable {
        case dm
        case group
        case channel
    }
}
