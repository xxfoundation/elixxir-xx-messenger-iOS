import Foundation
import KeychainAccess

public protocol KeychainHandling {
    func clear() throws
    func getPassword() throws -> Data?
    func store(password pwd: Data) throws
}

public struct KeychainHandler: KeychainHandling {
    private let password = "password"
    private let keychain: Keychain

    public init() {
        self.keychain = Keychain(service: "XXM")
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
}
