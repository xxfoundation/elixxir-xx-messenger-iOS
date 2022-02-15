extension Session {
    public func registerNotifications(_ string: String) throws {
        try client.bindings.registerNotifications(string)
    }

    public func unregisterNotifications() throws {
        try client.bindings.unregisterNotifications()
    }
}
