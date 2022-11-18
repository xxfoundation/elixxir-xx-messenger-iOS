import Combine
import Foundation

public struct ReportingStatusIsEnabled {
  public var get: () -> Bool
  public var set: (Bool) -> Void
  public var publisher: () -> AnyPublisher<Bool, Never>
}

extension ReportingStatusIsEnabled {
  public static func live(
    userDefaults: UserDefaults = .standard
  ) -> ReportingStatusIsEnabled {
    ReportingStatusIsEnabled(
      get: {
        userDefaults.isReportingEnabled
      },
      set: { enabled in
        userDefaults.isReportingEnabled = enabled
      },
      publisher: {
        userDefaults.publisher(for: \.isReportingEnabled).eraseToAnyPublisher()
      }
    )
  }
}

private extension UserDefaults {
  static let isReportingEnabledKey = "isReportingEnabled"
  
  @objc var isReportingEnabled: Bool {
    get {
      bool(forKey: Self.isReportingEnabledKey)
    } set {
      set(newValue, forKey: Self.isReportingEnabledKey)
    }
  }
}
