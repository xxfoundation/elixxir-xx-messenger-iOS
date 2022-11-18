import Combine
import Network

public struct NetworkMonitor {
  public enum Status: Equatable {
    case unknown
    case available
    case xxNotAvailable
    case internetNotAvailable
  }
  public enum ConnType: Equatable {
    case unknown
    case wifi
    case ethernet
    case cellular
  }

  public var start: StartNetworkMonitor
  public var update: UpdateNetworkStatus
  public var getStatus: GetNetworkStatus
  public var connType: GetNetworkConnType
  public var observeStatus: ObserveNetworkStatus
}

extension NetworkMonitor {
  public static func live() -> NetworkMonitor {
    class Context {
      var monitor = NWPathMonitor()
      let xxAvailability = CurrentValueSubject<Bool?, Never>(nil)
      let internetAvailability = CurrentValueSubject<Bool?, Never>(nil)
      let currentConnType = CurrentValueSubject<ConnType, Never>(.unknown)
    }

    let context = Context()

    return .init(
      start: .init {
        context.monitor.pathUpdateHandler = {
          let currentInterface: ConnType

          if $0.usesInterfaceType(.wifi) {
            currentInterface = .wifi
          } else if $0.usesInterfaceType(.wiredEthernet) {
            currentInterface = .ethernet
          } else if $0.usesInterfaceType(.cellular) {
            currentInterface = .cellular
          } else {
            currentInterface = .unknown
          }
          context.currentConnType.send(currentInterface)
          context.internetAvailability.send($0.status == .satisfied)
        }
        context.monitor.start(queue: .global())
      },
      update: .init {
        context.xxAvailability.send($0)
      },
      getStatus: .init {
        guard let xxAvailability = context.xxAvailability.value else {
          return .xxNotAvailable
        }
        return xxAvailability ? .available : .xxNotAvailable
      },
      connType: .init {
        context.currentConnType.value
      },
      observeStatus: .init {
        context
          .internetAvailability
          .combineLatest(context.xxAvailability)
          .map { (internet, xx) -> Status in
            guard let internet, let xx else { return .unknown}
            switch (internet, xx) {
            case (true, true):
              return .available
            case (true, false):
              return .xxNotAvailable
            case (false, _):
              return .internetNotAvailable
            }
          }.removeDuplicates()
          .eraseToAnyPublisher()
      }
    )
  }
}

extension NetworkMonitor {
  public static let unimplemented = NetworkMonitor(
    start: .unimplemented,
    update: .unimplemented,
    getStatus: .unimplemented,
    connType: .unimplemented,
    observeStatus: .unimplemented
  )
}
