import XXModels
import Foundation
import XXDatabase
import XXLegacyDatabaseMigrator

extension LaunchViewModel {
  func setupDatabase() throws {
    let legacyOldPath = NSSearchPathForDirectoriesInDomains(
      .documentDirectory, .userDomainMask, true
    )[0].appending("/xxmessenger.sqlite")

    let legacyPath = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: "group.elixxir.messenger")!
      .appendingPathComponent("database")
      .appendingPathExtension("sqlite").path

    let dbExistsInLegacyOldPath = FileManager.default.fileExists(atPath: legacyOldPath)
    let dbExistsInLegacyPath = FileManager.default.fileExists(atPath: legacyPath)

    if dbExistsInLegacyOldPath && !dbExistsInLegacyPath {
      try? FileManager.default.moveItem(atPath: legacyOldPath, toPath: legacyPath)
    }

    let dbPath = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: "group.elixxir.messenger")!
      .appendingPathComponent("xxm_database")
      .appendingPathExtension("sqlite").path

    let database = try Database.onDisk(path: dbPath)

    if dbExistsInLegacyPath {
      try Migrator.live()(
        try .init(path: legacyPath),
        to: database,
        myContactId: Data(), //client.bindings.myId,
        meMarshaled: Data() //client.bindings.meMarshalled
      )

      try FileManager.default.moveItem(atPath: legacyPath, toPath: legacyPath.appending("-backup"))
    }

    DI.Container.shared.register(database)

    _ = try? database.bulkUpdateContacts(.init(authStatus: [.requesting]), .init(authStatus: .requestFailed))
    _ = try? database.bulkUpdateContacts(.init(authStatus: [.confirming]), .init(authStatus: .confirmationFailed))
    _ = try? database.bulkUpdateContacts(.init(authStatus: [.verificationInProgress]), .init(authStatus: .verificationFailed))
  }

  func getContactWith(userId: Data) -> XXModels.Contact? {
    let query = Contact.Query(
      id: [userId],
      isBlocked: reportingStatus.isEnabled() ? false : nil,
      isBanned: reportingStatus.isEnabled() ? false : nil
    )

    guard let database: Database = try? DI.Container.shared.resolve(),
          let contact = try? database.fetchContacts(query).first else {
      return nil
    }

    return contact
  }

  func getGroupInfoWith(groupId: Data) -> GroupInfo? {
    let query = GroupInfo.Query(groupId: groupId)

    guard let database: Database = try? DI.Container.shared.resolve(),
          let info = try? database.fetchGroupInfos(query).first else {
      return nil
    }

    return info
  }
}
