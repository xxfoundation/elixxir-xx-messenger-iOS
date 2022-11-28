import Dependencies

private enum ProcessBannedListDependencyKey: DependencyKey {
  static let liveValue: ProcessBannedList = .live
  static let testValue: ProcessBannedList = .unimplemented
}

extension DependencyValues {
  public var processBannedList: ProcessBannedList {
    get { self[ProcessBannedListDependencyKey.self] }
    set { self[ProcessBannedListDependencyKey.self] = newValue }
  }
}
