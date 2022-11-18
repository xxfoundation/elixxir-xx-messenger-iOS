import Dependencies

private enum KeyObjectStoreDependencyKey: DependencyKey {
  static let liveValue: KeyObjectStore = .live
  static let testValue: KeyObjectStore = .unimplemented
}

extension DependencyValues {
  public var store: KeyObjectStore {
    get { self[KeyObjectStoreDependencyKey.self] }
    set { self[KeyObjectStoreDependencyKey.self] = newValue }
  }
}
