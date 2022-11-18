import Dependencies

private enum FetchBannedListDependencyKey: DependencyKey {
  static let liveValue: FetchBannedList = .live
  static let testValue: FetchBannedList = .unimplemented
}

extension DependencyValues {
  public var fetchBannedList: FetchBannedList {
    get { self[FetchBannedListDependencyKey.self] }
    set { self[FetchBannedListDependencyKey.self] = newValue }
  }
}

