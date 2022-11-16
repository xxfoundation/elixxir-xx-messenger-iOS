import Combine
import Network

public struct NetworkMonitorManager {
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

  public var start: NetworkMonitorStart
  public var update: NetworkMonitorUpdate
  public var status: NetworkMonitorStatus
  public var connType: NetworkMonitorConnType
}

extension NetworkMonitorManager {
  public static func live() -> NetworkMonitorManager {
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
      status: .init {
        guard let xxAvailability = context.xxAvailability.value else {
          return .xxNotAvailable
        }
        return xxAvailability ? .available : .xxNotAvailable
      },
      connType: .init {
        context.currentConnType.value
      }
    )
  }
}

extension NetworkMonitorManager {
  public static let unimplemented = NetworkMonitorManager(
    start: .unimplemented,
    update: .unimplemented,
    status: .unimplemented,
    connType: .unimplemented
  )
}
