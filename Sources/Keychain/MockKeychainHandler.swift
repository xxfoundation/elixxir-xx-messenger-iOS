import Foundation

public struct MockKeychainHandler: KeychainHandling {
    public init() {}

    public func clear() throws {}
    public func store(password pwd: Data) throws {}
    public func getPassword() throws -> Data? { Data() }
}
