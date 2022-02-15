import Foundation
import DependencyInjection

public enum Key: String {
    // MARK: Profile

    case email
    case phone
    case avatar
    case username

    case sharingEmail
    case sharingPhone

    // MARK: Notifications

    case requestCounter
    case pushNotifications
    case inappnotifications

    // MARK: General

    case theme

    // MARK: Settings

    case biometrics
    case hideAppList
    case recordingLogs
    case crashReporting
    case icognitoKeyboard
    case openedSettingsFirstTime

    case dummyTrafficOn
    case askedDummyTrafficOnce
}

public struct KeyObjectStore {
    var objectForKey: (String) -> Any?
    var setObjectForKey: (Any?, String) -> Void
    var removeObjectForKey: (String) -> Void

    public init(
        objectForKey: @escaping (String) -> Any?,
        setObjectForKey: @escaping (Any?, String) -> Void,
        removeObjectForKey: @escaping (String) -> Void
    ) {
        self.objectForKey = objectForKey
        self.setObjectForKey = setObjectForKey
        self.removeObjectForKey = removeObjectForKey
    }
}

public extension KeyObjectStore {
    static func mock(dictionary: NSMutableDictionary) -> Self {
        Self(objectForKey: { dictionary[$0] },
             setObjectForKey: { dictionary[$1] = $0 },
             removeObjectForKey: { dictionary[$0] = nil })
    }

    static let userDefaults = Self(
        objectForKey: UserDefaults.standard.object(forKey:),
        setObjectForKey: UserDefaults.standard.set(_:forKey:),
        removeObjectForKey: UserDefaults.standard.removeObject(forKey:)
    )
}

@propertyWrapper
public struct KeyObject<T> {
    let key: String
    let defaultValue: T

    @Dependency var store: KeyObjectStore

    public init(_ key: Key, defaultValue: T) {
        self.key = key.rawValue
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            store.objectForKey(key) as? T ?? defaultValue
        }
        set {
            if let value = newValue as? OptionalProtocol, value.isNil() {
                store.removeObjectForKey(key)
            } else {
                store.setObjectForKey(newValue, key)
            }
        }
    }
}

fileprivate protocol OptionalProtocol {
    func isNil() -> Bool
}

extension Optional : OptionalProtocol {
    func isNil() -> Bool {
        return self == nil
    }
}
