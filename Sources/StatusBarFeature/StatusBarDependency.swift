import Dependencies

private enum StatusBarDependencyKey: DependencyKey {
  static let liveValue: StatusBarStyleManager = .live()
  static let testValue: StatusBarStyleManager = .unimplemented
}

extension DependencyValues {
  public var statusBar: StatusBarStyleManager {
    get { self[StatusBarDependencyKey.self] }
    set { self[StatusBarDependencyKey.self] = newValue }
  }
}
