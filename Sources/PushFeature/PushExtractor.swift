import XXModels
import Foundation
import DependencyInjection

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
        NSLog("EXTRACTING PUSH A...")

        guard let database = try? DependencyInjection.Container.shared.resolve() as Database,
              let anyone = try? database.fetchContacts(.init()).first else {
            NSLog("EXTRACTING PUSH B...")
            return .success(nil)
        }

        NSLog("EXTRACTING PUSH C...")

        return .success([.init(type: PushType.request.rawValue, source: anyone.id)!])

//        guard let messenger = try? DependencyInjection.Container.shared.resolve() as Messenger,
//              let data = dictionary[Constants.notificationData] as? String else {
//            return .success(nil)
//        }
//
//        do {
//            let reportFunctor = GetNotificationsReport.live()
//            let report = try reportFunctor(
//                e2eId: messenger.e2e.get()!.getId(),
//                notificationCSV: data,
//                marshaledServices: Data() // <--- ???
//            )
//
//            guard report.forMe,
//                  report.type != .silent,
//                  report.type != .default
//            else {
//                return .success(nil)
//            }
//
//            return .success([Push(
//                type: report.type.rawValue,
//                source: report.source)!
//            ])
//        } catch {
//            return .failure(error)
//        }
    }
}
