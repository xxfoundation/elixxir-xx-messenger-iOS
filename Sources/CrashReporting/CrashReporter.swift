import Foundation

public struct CrashReporter {
  public var configure: () -> Void
  public var sendError: (NSError) -> Void
  public var setEnabled: (Bool) -> Void

  public init(
    configure: @escaping () -> Void,
    sendError: @escaping (NSError) -> Void,
    setEnabled: @escaping (Bool) -> Void
  ) {
    self.configure = configure
    self.sendError = sendError
    self.setEnabled = setEnabled
  }
}

public extension CrashReporter {
  static let noop = Self(
    configure: {},
    sendError: { _ in },
    setEnabled: { _ in }
  )
}
