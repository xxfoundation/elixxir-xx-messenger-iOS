import Dependencies

private enum UpdateErrorsDependencyKey: DependencyKey {
  static let liveValue: UpdateErrors = .live
  static let testValue: UpdateErrors = .unimplemented
}

extension DependencyValues {
  public var updateErrors: UpdateErrors {
    get { self[UpdateErrorsDependencyKey.self] }
    set { self[UpdateErrorsDependencyKey.self] = newValue }
  }
}
