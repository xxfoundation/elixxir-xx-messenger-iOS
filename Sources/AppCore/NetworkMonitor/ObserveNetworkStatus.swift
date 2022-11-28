import Combine
import XCTestDynamicOverlay

public struct ObserveNetworkStatus {
  public init(run: @escaping () -> AnyPublisher<NetworkMonitor.Status, Never>) {
    self.run = run
  }

  public var run: () -> AnyPublisher<NetworkMonitor.Status, Never>

  public func callAsFunction() -> AnyPublisher<NetworkMonitor.Status, Never> {
    run()
  }
}

extension ObserveNetworkStatus {
  public static let unimplemented = ObserveNetworkStatus(
    run: XCTUnimplemented("\(Self.self)")
  )
}
