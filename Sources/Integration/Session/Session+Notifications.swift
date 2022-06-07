import Foundation

extension Session {
    public func registerNotifications(_ token: Data) throws {
        try client.bindings.registerNotifications(token)
    }

    public func unregisterNotifications() throws {
        try client.bindings.unregisterNotifications()
    }
}
