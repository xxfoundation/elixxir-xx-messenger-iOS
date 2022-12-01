import XXModels
import Foundation
import XXDatabase
import XCTestDynamicOverlay

public struct DBManagerRemoveDB {
  public var run: () throws -> Void

  public func callAsFunction() throws -> Void {
    try run()
  }
}

extension DBManagerRemoveDB {
  public static func live(
    url: URL,
    getDB: @escaping () -> Database?,
    unsetDB: @escaping () -> Void
  ) -> DBManagerRemoveDB {
    DBManagerRemoveDB {
      let db = getDB()
      unsetDB()
      try db?.drop()
      let fm = FileManager.default
      if fm.fileExists(atPath: url.path), url.startAccessingSecurityScopedResource() {
        do {
          try fm.removeItem(atPath: url.path)
          url.stopAccessingSecurityScopedResource()
        } catch {
          url.stopAccessingSecurityScopedResource()
          throw error
        }
      }
    }
  }
}

extension DBManagerRemoveDB {
  public static let unimplemented = DBManagerRemoveDB(
    run: XCTUnimplemented("\(Self.self)")
  )
}
