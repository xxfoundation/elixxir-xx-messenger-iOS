import Firebase
import CrashReporting
import FirebaseCrashlytics
import XCTestDynamicOverlay

public struct CrashReport {
  public var configure: () -> Void
  public var sendError: (NSError) -> Void
  public var setEnabled: (Bool) -> Void
}

extension CrashReport {
  public static let live = CrashReport(
    configure: FirebaseApp.configure,
    sendError: Crashlytics.crashlytics().record(error:),
    setEnabled: Crashlytics.crashlytics().setCrashlyticsCollectionEnabled
  )
}

extension CrashReport {
  public static let unimplemented = CrashReport(
    configure: XCTUnimplemented("\(Self.self)"),
    sendError: XCTUnimplemented("\(Self.self)"),
    setEnabled: XCTUnimplemented("\(Self.self)")
  )
}
