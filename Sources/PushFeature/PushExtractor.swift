import Foundation
import Integration

public struct PushExtractor {
    enum Constants {
        static let preImage = "preImage"
        static let appGroup = "group.elixxir.messenger"
        static let notificationData = "notificationData"
    }

    public var extractFrom: ([AnyHashable: Any]) -> Result<[Push]?, Error>
}

public extension PushExtractor {
    static let live = PushExtractor { dictionary in
        var error: NSError?

        guard let data = dictionary[Constants.notificationData] as? String,
              let defaults = UserDefaults(suiteName: Constants.appGroup),
              let preImage = defaults.value(forKey: Constants.preImage) as? String,
              let reports = evaluateNotification(data, preImage, &error) else {
            return .success(nil)
        }

        if let error = error {
            return .failure(error)
        }

        let pushes = (0..<reports.len())
            .compactMap { try? reports.get(index: $0) }
            .filter { $0.forMe() }
            .filter { $0.type() != PushType.silent.rawValue }
            .filter { $0.type() != PushType.default.rawValue }
            .compactMap { Push(type: $0.type(), source: $0.source()) }

        return .success(pushes)
    }
}
