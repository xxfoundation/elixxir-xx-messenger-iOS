import Foundation

public struct Push {
    public let type: PushType
    public let source: Data?

    public init?(type: String, source: Data?) {
        guard let pushType = PushType(rawValue: type) else {
            return nil
        }

        self.type = pushType
        self.source = source
    }
}
