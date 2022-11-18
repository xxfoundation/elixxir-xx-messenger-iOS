public struct KeychainManager {
  public var set: SetValueForKey
  public var get: GetValueForKey
  public var remove: RemoveValueForKey
  public var destroy: DestroyKeychain
}

extension KeychainManager {
  public static let live = KeychainManager(
    set: .live,
    get: .live,
    remove: .live,
    destroy: .live
  )
}

extension KeychainManager {
  public static let unimplemented = KeychainManager(
    set: .unimplemented,
    get: .unimplemented,
    remove: .unimplemented,
    destroy: .unimplemented
  )
}
