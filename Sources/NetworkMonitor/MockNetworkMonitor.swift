import Combine
import Foundation

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
        simulateOscilation(.available)
    }

    public func update(_ status: Bool) {
        // TODO
    }

    private func simulateOscilation(_ status: NetworkStatus) {
        statusRelay.send(status)

        if status == .available {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                simulateOscilation(.internetNotAvailable)
            }
        } else if status == .internetNotAvailable {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                simulateOscilation(.available)
            }
        }
    }
}
