// https://www.reddit.com/r/swift/comments/ir8wn5/network_connectivity_is_always_unsatisfied_when/

import Network
import Combine

public enum NetworkStatus: Equatable {
    case unknown
    case available
    case xxNotAvailable
    case internetNotAvailable
}

public protocol NetworkMonitoring {
    func start()
    func update(_ status: Bool)

    var xxStatus: NetworkStatus { get }
    var statusPublisher: AnyPublisher<NetworkStatus, Never> { get }
}

public struct NetworkMonitor: NetworkMonitoring {
    public init() {}

    private var monitor = NWPathMonitor()
    private let isXXAvailableRelay = CurrentValueSubject<Bool?, Never>(nil)
    private let isInternetAvailableRelay = CurrentValueSubject<Bool?, Never>(nil)

    public var xxStatus: NetworkStatus {
        isXXAvailableRelay.value == true ? .available : .xxNotAvailable
    }

    public var statusPublisher: AnyPublisher<NetworkStatus, Never> {
        isInternetAvailableRelay.combineLatest(isXXAvailableRelay)
            .map { (isInternetAvailable, isXXAvailable) -> NetworkStatus in

                guard let isInternetAvailable = isInternetAvailable,
                      let isXXAvailable = isXXAvailable else { return .unknown }

                switch (isInternetAvailable, isXXAvailable) {
                case (true, true):
                    return .available
                case (true, false):
                    return .xxNotAvailable
                case (false, _):
                    return .internetNotAvailable
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func start() {
        monitor.pathUpdateHandler = { [weak isInternetAvailableRelay] in
            isInternetAvailableRelay?.send($0.status == .satisfied)
        }

        monitor.start(queue: .global())
    }

    public func update(_ status: Bool) {
        isXXAvailableRelay.send(status)
    }
}
