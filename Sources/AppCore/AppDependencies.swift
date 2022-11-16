import Foundation
import XXMessengerClient
import XCTestDynamicOverlay
import ComposableArchitecture

public struct AppDependencies {
  public var networkMonitor: NetworkMonitorManager
  public var toastManager: ToastManager
  public var hudManager: HUDManager
  public var dbManager: DBManager
  public var messenger: Messenger
  public var authHandler: AuthCallbackHandler
  public var backupStorage: BackupStorage
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
  public var now: () -> Date
  public var sendMessage: SendMessage
  public var sendImage: SendImage
  public var messageListener: MessageListenerHandler
  public var receiveFileHandler: ReceiveFileHandler
  public var log: Logger
  public var loadData: URLDataLoader
}

extension AppDependencies {
  public static func live() -> AppDependencies {
    let dbManager = DBManager.live()
    var messengerEnv = MessengerEnvironment.live()
    messengerEnv.udEnvironment = .init(
      address: Constants.address,
      cert: Constants.cert.data(using: .utf8)!,
      contact: Constants.contact.data(using: .utf8)!
    )
    messengerEnv.serviceList = .userDefaults(
      key: "preImage",
      userDefaults: UserDefaults(suiteName: "group.elixxir.messenger")!
    )
    let messenger = Messenger.live(messengerEnv)
    let now: () -> Date = Date.init

    return AppDependencies(
      networkMonitor: .live(),
      toastManager: .live(),
      hudManager: .live(),
      dbManager: dbManager,
      messenger: messenger,
      authHandler: .live(
        messenger: messenger,
        handleRequest: .live(db: dbManager.getDB, now: now),
        handleConfirm: .live(db: dbManager.getDB),
        handleReset: .live(db: dbManager.getDB)
      ),
      backupStorage: .onDisk(),
      mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
      bgQueue: DispatchQueue.global(qos: .background).eraseToAnyScheduler(),
      now: now,
      sendMessage: .live(
        messenger: messenger,
        db: dbManager.getDB,
        now: now
      ),
      sendImage: .live(
        messenger: messenger,
        db: dbManager.getDB,
        now: now
      ),
      messageListener: .live(
        messenger: messenger,
        db: dbManager.getDB
      ),
      receiveFileHandler: .live(
        messenger: messenger,
        db: dbManager.getDB,
        now: now
      ),
      log: .live(),
      loadData: .live
    )
  }

  public static let unimplemented = AppDependencies(
    networkMonitor: .unimplemented,
    toastManager: .unimplemented,
    hudManager: .unimplemented,
    dbManager: .unimplemented,
    messenger: .unimplemented,
    authHandler: .unimplemented,
    backupStorage: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented,
    now: XCTestDynamicOverlay.unimplemented(
      "\(Self.self)",
      placeholder: Date(timeIntervalSince1970: 0)
    ),
    sendMessage: .unimplemented,
    sendImage: .unimplemented,
    messageListener: .unimplemented,
    receiveFileHandler: .unimplemented,
    log: .unimplemented,
    loadData: .unimplemented
  )
}

private enum AppDependenciesKey: DependencyKey {
  static let liveValue: AppDependencies = .live()
  static let testValue: AppDependencies = .unimplemented
}

extension DependencyValues {
  public var app: AppDependencies {
    get { self[AppDependenciesKey.self] }
    set { self[AppDependenciesKey.self] = newValue }
  }
}

private enum Constants {
  static let address = "46.101.98.49:18001"
  static let cert = """
-----BEGIN CERTIFICATE-----
MIIDbDCCAlSgAwIBAgIJAOUNtZneIYECMA0GCSqGSIb3DQEBBQUAMGgxCzAJBgNV
BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlDbGFyZW1vbnQx
GzAZBgNVBAoMElByaXZhdGVncml0eSBDb3JwLjETMBEGA1UEAwwKKi5jbWl4LnJp
cDAeFw0xOTAzMDUxODM1NDNaFw0yOTAzMDIxODM1NDNaMGgxCzAJBgNVBAYTAlVT
MRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlDbGFyZW1vbnQxGzAZBgNV
BAoMElByaXZhdGVncml0eSBDb3JwLjETMBEGA1UEAwwKKi5jbWl4LnJpcDCCASIw
DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPP0WyVkfZA/CEd2DgKpcudn0oDh
Dwsjmx8LBDWsUgQzyLrFiVigfUmUefknUH3dTJjmiJtGqLsayCnWdqWLHPJYvFfs
WYW0IGF93UG/4N5UAWO4okC3CYgKSi4ekpfw2zgZq0gmbzTnXcHF9gfmQ7jJUKSE
tJPSNzXq+PZeJTC9zJAb4Lj8QzH18rDM8DaL2y1ns0Y2Hu0edBFn/OqavBJKb/uA
m3AEjqeOhC7EQUjVamWlTBPt40+B/6aFJX5BYm2JFkRsGBIyBVL46MvC02MgzTT9
bJIJfwqmBaTruwemNgzGu7Jk03hqqS1TUEvSI6/x8bVoba3orcKkf9HsDjECAwEA
AaMZMBcwFQYDVR0RBA4wDIIKKi5jbWl4LnJpcDANBgkqhkiG9w0BAQUFAAOCAQEA
neUocN4AbcQAC1+b3To8u5UGdaGxhcGyZBlAoenRVdjXK3lTjsMdMWb4QctgNfIf
U/zuUn2mxTmF/ekP0gCCgtleZr9+DYKU5hlXk8K10uKxGD6EvoiXZzlfeUuotgp2
qvI3ysOm/hvCfyEkqhfHtbxjV7j7v7eQFPbvNaXbLa0yr4C4vMK/Z09Ui9JrZ/Z4
cyIkxfC6/rOqAirSdIp09EGiw7GM8guHyggE4IiZrDslT8V3xIl985cbCxSxeW1R
tgH4rdEXuVe9+31oJhmXOE9ux2jCop9tEJMgWg7HStrJ5plPbb+HmjoX3nBO04E5
6m52PyzMNV+2N21IPppKwA==
-----END CERTIFICATE-----
"""
  static let contact = """
<xxc(2)7mbKFLE201WzH4SGxAOpHjjehwztIV+KGifi5L/PYPcDkAZiB9kZo+Dl3Vc7dD2SdZCFMOJVgwqGzfYRDkjc8RGEllBqNxq2sRRX09iQVef0kJQUgJCHNCOcvm6Ki0JJwvjLceyFh36iwK8oLbhLgqEZY86UScdACTyBCzBIab3ob5mBthYc3mheV88yq5PGF2DQ+dEvueUm+QhOSfwzppAJA/rpW9Wq9xzYcQzaqc3ztAGYfm2BBAHS7HVmkCbvZ/K07Xrl4EBPGHJYq12tWAN/C3mcbbBYUOQXyEzbSl/mO7sL3ORr0B4FMuqCi8EdlD6RO52pVhY+Cg6roRH1t5Ng1JxPt8Mv1yyjbifPhZ5fLKwxBz8UiFORfk0/jnhwgm25LRHqtNRRUlYXLvhv0HhqyYTUt17WNtCLATSVbqLrFGdy2EGadn8mP+kQNHp93f27d/uHgBNNe7LpuYCJMdWpoG6bOqmHEftxt0/MIQA8fTtTm3jJzv+7/QjZJDvQIv0SNdp8HFogpuwde+GuS4BcY7v5xz+ArGWcRR63ct2z83MqQEn9ODr1/gAAAgA7szRpDDQIdFUQo9mkWg8xBA==xxc>
"""
}
