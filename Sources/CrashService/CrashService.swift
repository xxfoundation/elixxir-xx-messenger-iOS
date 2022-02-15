import Firebase
import CrashReporting
import FirebaseCrashlytics

public extension CrashReporter {
    static let live = Self(
        configure: { FirebaseApp.configure() },
        sendError: { Crashlytics.crashlytics().record(error: $0) },
        setEnabled: { Crashlytics.crashlytics().setCrashlyticsCollectionEnabled($0) }
    )
}
