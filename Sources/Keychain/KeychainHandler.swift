import Foundation
import KeychainAccess

public enum KeychainSFTP: String {
  case pwd
  case host
  case username
}

public protocol KeychainHandling {
  func clear() throws
  func getPassword() throws -> Data?
  func remove(_ key: String) throws
  func store(password pwd: Data) throws

  func get(key: KeychainSFTP) throws -> String?
  func store(key: KeychainSFTP, value: String) throws
}

public struct KeychainHandler: KeychainHandling {
  private let keychain: Keychain
  private let password = "password"

  public init() {
    self.keychain = Keychain(service: "XXM")
  }

  public func remove(_ key: String) throws {
    try keychain.remove(key)
  }

  public func clear() throws {
    try keychain.removeAll()
  }

  public func store(password pwd: Data) throws {
    try keychain.set(pwd, key: password)
  }

  public func getPassword() throws -> Data? {
    try keychain.getData(password)
  }

  public func get(key: KeychainSFTP) throws -> String? {
    try keychain.get(key.rawValue)
  }

  public func store(key: KeychainSFTP, value: String) throws {
    try keychain.set(value, key: key.rawValue)
  }
}
