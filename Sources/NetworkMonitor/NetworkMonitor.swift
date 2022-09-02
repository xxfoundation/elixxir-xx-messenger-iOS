// https://www.reddit.com/r/swift/comments/ir8wn5/network_connectivity_is_always_unsatisfied_when/

import Network
import Combine
import XXClient
import Foundation

public enum NetworkStatus: Equatable {
    case unknown
    case available
    case xxNotAvailable
    case internetNotAvailable
}

public enum ConnectionType {
    case wifi
    case ethernet
    case cellular
    case unknown
}

public protocol NetworkMonitoring {
    func start()
    func update(_ status: Bool)

    var xxStatus: NetworkStatus { get }
    var connType: AnyPublisher<ConnectionType, Never> { get }
    var statusPublisher: AnyPublisher<NetworkStatus, Never> { get }
}

public struct NetworkMonitor: NetworkMonitoring {
    public init() {}

    private var monitor = NWPathMonitor()
    private let isXXAvailableRelay = CurrentValueSubject<Bool?, Never>(nil)
    private let isInternetAvailableRelay = CurrentValueSubject<Bool?, Never>(nil)
    private let connTypeSubject = PassthroughSubject<ConnectionType, Never>()

    public var xxStatus: NetworkStatus {
        isXXAvailableRelay.value == true ? .available : .xxNotAvailable
    }

    public var connType: AnyPublisher<ConnectionType, Never> {
        connTypeSubject.eraseToAnyPublisher()
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
        monitor.pathUpdateHandler = { [weak isInternetAvailableRelay, weak connTypeSubject] in
            connTypeSubject?.send(checkConnectionTypeForPath($0))
            isInternetAvailableRelay?.send($0.status == .satisfied)
        }

        monitor.start(queue: .global())
    }

    public func update(_ status: Bool) {
        isXXAvailableRelay.send(status)
    }

    private func checkConnectionTypeForPath(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        }

        return .unknown
    }
}
