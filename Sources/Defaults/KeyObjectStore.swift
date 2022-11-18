public struct KeyObjectStore {
  public var get: ObjectForKey
  public var set: SetObjectForKey
  public var remove: RemoveObjectForKey
}

extension KeyObjectStore {
  public static let live = KeyObjectStore(
    get: .live,
    set: .live,
    remove: .live
  )
}

extension KeyObjectStore {
  public static let unimplemented = KeyObjectStore(
    get: .unimplemented,
    set: .unimplemented,
    remove: .unimplemented
  )
}
