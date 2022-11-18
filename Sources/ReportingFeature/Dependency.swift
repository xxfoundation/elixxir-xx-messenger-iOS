import Dependencies

private enum ReportingStatusDependencyKey: DependencyKey {
  static let liveValue: ReportingStatus = .live()
  static let testValue: ReportingStatus = .unimplemented
}

extension DependencyValues {
  public var reportingStatus: ReportingStatus {
    get { self[ReportingStatusDependencyKey.self] }
    set { self[ReportingStatusDependencyKey.self] = newValue }
  }
}
  
private enum SendReportDependencyKey: DependencyKey {
  static let liveValue: SendReport = .live
  static let testValue: SendReport = .unimplemented
}

extension DependencyValues {
  public var sendReport: SendReport {
    get { self[SendReportDependencyKey.self] }
    set { self[SendReportDependencyKey.self] = newValue }
  }
}
