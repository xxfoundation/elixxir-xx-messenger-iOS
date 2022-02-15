import Foundation

extension Session {
    public func start() {
        DispatchQueue.global().async { [weak client] in
            client?.bindings.startNetwork()
        }
    }

    public func stop() {
        DispatchQueue.global().async { [weak client] in
            client?.bindings.stopNetwork()
        }
    }
}
