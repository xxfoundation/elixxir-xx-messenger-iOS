import Combine

public struct MockNetworkMonitor: NetworkMonitoring {
    private let statusRelay = PassthroughSubject<NetworkStatus, Never>()

    public var connType: AnyPublisher<ConnectionType, Never> {
        Just(.wifi).eraseToAnyPublisher()
    }

    public var statusPublisher: AnyPublisher<NetworkStatus, Never> {
        statusRelay.eraseToAnyPublisher()
    }

    public var xxStatus: NetworkStatus {
        .available
    }

    public init() {
        // TODO
    }

    public func start() {
        // TODO
    }

    public func update(_ status: Bool) {
        // TODO
    }
}
