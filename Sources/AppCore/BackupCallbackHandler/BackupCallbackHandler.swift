import XXClient
import Foundation
import XXMessengerClient
import XCTestDynamicOverlay

public struct BackupCallbackHandler {
  public typealias OnError = (Error) -> Void

  public var run: (@escaping OnError) -> Cancellable

  public func callAsFunction(onError: @escaping OnError) -> Cancellable {
    run(onError)
  }
}

extension BackupCallbackHandler {
  public static func live(
    messenger: Messenger
  ) -> BackupCallbackHandler {
    BackupCallbackHandler { onError in
      let callback = UpdateBackupFunc { data in
        do {
          let url = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
          )
            .appendingPathComponent("backup")
            .appendingPathExtension("xxm")
          try data.write(to: url)
        } catch {
          onError(error)
        }
      }
      return messenger.registerBackupCallback(callback)
    }
  }
}

extension BackupCallbackHandler {
  public static let unimplemented = BackupCallbackHandler(
    run: XCTUnimplemented("\(Self.self)", placeholder: Cancellable {})
  )
}
