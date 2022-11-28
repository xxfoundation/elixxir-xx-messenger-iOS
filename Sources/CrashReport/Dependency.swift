import Dependencies

private enum CrashReportDependencyKey: DependencyKey {
  static let liveValue: CrashReport = .live
  static let testValue: CrashReport = .unimplemented
}

extension DependencyValues {
  public var crashReport: CrashReport {
    get { self[CrashReportDependencyKey.self] }
    set { self[CrashReportDependencyKey.self] = newValue }
  }
}
