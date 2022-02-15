import Combine

public struct MockNetworkMonitor: NetworkMonitoring {
    private let statusRelay = PassthroughSubject<NetworkStatus, Never>()
    public var statusPublisher: AnyPublisher<NetworkStatus, Never> { statusRelay.eraseToAnyPublisher() }

    public var xxStatus: NetworkStatus { .available }

    public init() {}
    public func start() {}
    public func update(_ status: Bool) {}
}
