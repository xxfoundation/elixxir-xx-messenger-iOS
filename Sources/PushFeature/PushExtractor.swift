import XXModels
import Foundation
import XXClient
import XXMessengerClient
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
    var environment: MessengerEnvironment = .live()
    environment.ndfEnvironment = .mainnet
    environment.serviceList = .userDefaults(
      key: "preImage",
      userDefaults: UserDefaults(suiteName: "group.elixxir.messenger")!
    )
    let messenger = Messenger.live(environment)
    guard let csv = dictionary[Constants.notificationData] as? String,
          let defaults = UserDefaults(suiteName: Constants.appGroup) else {
      return .success(nil)
    }
    do {
      let report = try messenger.getNotificationReport(notificationCSV: csv)
      guard report.forMe,
            report.type != .silent,
            report.type != .default
      else {
        return .success(nil)
      }
      return .success([Push(
        type: report.type,
        source: report.source
      )])
    } catch {
      return .failure(error)
    }
  }
}
