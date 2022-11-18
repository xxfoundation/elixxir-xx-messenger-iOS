import Foundation
import ComposableArchitecture

public enum Key: String {
  case email
  case phone
  case avatar
  case username
  case sharingEmail
  case sharingPhone
  case requestCounter
  case pushNotifications
  case inappnotifications
  case acceptedTerms
  case isShowingHiddenRequests
  case backupSettings
  case biometrics
  case hideAppList
  case recordingLogs
  case crashReporting
  case icognitoKeyboard
  case dummyTrafficOn
  case askedDummyTrafficOnce
}

@propertyWrapper
public struct KeyObject<T> {
  let key: String
  let defaultValue: T

  @Dependency(\.store) var store: KeyObjectStore

  public init(_ key: Key, defaultValue: T) {
    self.key = key.rawValue
    self.defaultValue = defaultValue
  }

  public var wrappedValue: T {
    get {
      store.get(key) as? T ?? defaultValue
    }
    set {
      if let value = newValue as? OptionalProtocol, value.isNil() {
        store.remove(key)
      } else {
        store.set(newValue, for: key)
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
