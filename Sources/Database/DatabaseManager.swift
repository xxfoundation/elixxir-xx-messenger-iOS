import GRDB
import Models
import Combine
import Foundation

public protocol Requestable: FetchableRecord {
    associatedtype Request
    static func query(_ request: Request) -> QueryInterfaceRequest<Self>
}

public protocol Persistable: Requestable & MutablePersistableRecord & Identifiable {
    var id: Int64? { get }
}

public protocol DatabaseManager {
    func drop()
    func setup() throws

    func updateAll<T>(_ type: T.Type,
                      _ request: T.Request,
                      with: [ColumnAssignment]) throws where T: Persistable

    @discardableResult func save<T>(_ model: T) throws -> T where T: Persistable
    func update<T>(_ model: T) throws where T: Persistable
    func delete<T>(_ model: T) throws where T: Persistable
    func fetch<T>(_ request: T.Request) throws -> [T] where T: Requestable
    func fetch<T>(withId id: Int64) throws -> T? where T: Persistable
    func publisher<T>(fetch request: T.Request) -> AnyPublisher<[T], Error> where T: Requestable
    func delete<T>(_ type: T.Type, _ request: T.Request) throws where T: Persistable
}

public extension DatabaseManager {
    func publisher<T: Requestable>(
        fetch type: T.Type,
        _ request: T.Request
    ) -> AnyPublisher<[T], Error> {
        publisher(fetch: request)
    }
}

public final class GRDBDatabaseManager {
    var databaseQueue: DatabaseQueue!
    var databaseMigrator: DatabaseMigrator!

    public init() {}
}

extension GRDBDatabaseManager: DatabaseManager {
    public func drop() {
        try? databaseQueue.write { db in
            try db.drop(table: Contact.databaseTableName)
            try db.drop(table: Message.databaseTableName)
            try db.drop(table: Group.databaseTableName)
            try db.drop(table: GroupMember.databaseTableName)
            try db.drop(table: GroupMessage.databaseTableName)
        }
    }

    public func updateAll<T>(_ type: T.Type,
                             _ request: T.Request,
                             with assignments: [ColumnAssignment]) throws where T : Persistable {
        _ = try databaseQueue.write {
            try T.query(request).updateAll($0, assignments)
        }
    }

    public func save<T: Persistable>(_ model: T) throws -> T {
        try databaseQueue.write { db in
            var model = model

            if model.id == nil {
                try model.insert(db)
            } else {
                try model.update(db)
            }

            return model
        }
    }

    public func update<T>(_ model: T) throws where T: Persistable {
        try databaseQueue.write { try model.update($0) }
    }

    public func fetch<T>(withId id: Int64) throws -> T? where T: Persistable {
        try databaseQueue.read { db in
            try T.fetchOne(db, key: id)
        }
    }

    public func fetch<T>(_ request: T.Request) throws -> [T] where T: Requestable {
        try databaseQueue.read { db in
            try T.query(request).fetchAll(db)
        }
    }

    public func publisher<T>(fetch request: T.Request) -> AnyPublisher<[T], Error> where T: Requestable {
        ValueObservation.tracking {
            try T.query(request).fetchAll($0)
        }.publisher(in: databaseQueue, scheduling: .immediate)
        .eraseToAnyPublisher()
    }

    public func delete<T>(_ model: T) throws where T: Persistable {
        _ = try databaseQueue.write {
            try model.delete($0)
        }
    }

    public func delete<T>(_ type: T.Type, _ request: T.Request) throws where T: Persistable {
        _ = try databaseQueue.write {
            try T.query(request).deleteAll($0)
        }
    }

    public func setup() throws {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        )[0]
        .appending("/xxmessenger.sqlite")

        databaseQueue = try DatabaseQueue(path: path)
        try FileManager.default.setAttributes([
            .protectionKey : FileProtectionType.completeUntilFirstUserAuthentication
        ], ofItemAtPath: path)

        try databaseQueue.write { db in
            try db.create(table: Contact.databaseTableName, ifNotExists: true) { table in
                table.autoIncrementedPrimaryKey(Contact.Column.id.rawValue, onConflict: .replace)
                table.column(Contact.Column.photo.rawValue, .blob)
                table.column(Contact.Column.email.rawValue, .text)
                table.column(Contact.Column.phone.rawValue, .text)
                table.column(Contact.Column.nickname.rawValue, .text)
                table.column(Contact.Column.createdAt.rawValue, .datetime)
                table.column(Contact.Column.userId.rawValue, .blob).unique()
                table.column(Contact.Column.username.rawValue, .text).notNull()
                table.column(Contact.Column.status.rawValue, .integer).notNull()
                table.column(Contact.Column.marshaled.rawValue, .blob).notNull()
            }

            try db.create(table: Message.databaseTableName, ifNotExists: true) { table in
                table.autoIncrementedPrimaryKey(Message.Column.id.rawValue, onConflict: .replace)
                table.column(Message.Column.report.rawValue, .blob)
                table.column(Message.Column.uniqueId.rawValue, .blob)
                table.column(Message.Column.sender.rawValue, .blob).notNull()
                table.column(Message.Column.payload.rawValue, .text).notNull()
                table.column(Message.Column.receiver.rawValue, .blob).notNull()
                table.column(Message.Column.roundURL.rawValue, .text)
                table.column(Message.Column.status.rawValue, .integer).notNull()
                table.column(Message.Column.unread.rawValue, .boolean).notNull()
                table.column(Message.Column.timestamp.rawValue, .integer).notNull()
            }

            try db.create(table: Group.databaseTableName, ifNotExists: true) { table in
                table.autoIncrementedPrimaryKey(Group.Column.id.rawValue, onConflict: .replace)
                table.column(Group.Column.groupId.rawValue, .blob).unique()
                table.column(Group.Column.name.rawValue, .text).notNull()
                table.column(Group.Column.leader.rawValue, .blob).notNull()
                table.column(Group.Column.serialize.rawValue, .blob).notNull()
                table.column(Group.Column.accepted.rawValue, .boolean).notNull()
            }

            try db.create(table: GroupMember.databaseTableName, ifNotExists: true) { table in
                table.autoIncrementedPrimaryKey(GroupMember.Column.id.rawValue, onConflict: .replace)
                table.column(GroupMember.Column.userId.rawValue, .blob).notNull()
                table.column(GroupMember.Column.username.rawValue, .text).notNull()
                table.column(GroupMember.Column.photo.rawValue, .blob)
                table.column(GroupMember.Column.status.rawValue, .integer).notNull()
                table.column(GroupMember.Column.groupId.rawValue, .blob).notNull()
                    .references(
                        Group.databaseTableName,
                        column: Group.Column.groupId.rawValue,
                        onDelete: .cascade,
                        deferred: true
                    )
            }

            try db.create(table: GroupMessage.databaseTableName, ifNotExists: true) { table in
                table.autoIncrementedPrimaryKey(GroupMessage.Column.id.rawValue, onConflict: .replace)
                table.column(GroupMessage.Column.uniqueId.rawValue, .blob)
                table.column(GroupMessage.Column.roundId.rawValue, .integer)
                table.column(GroupMessage.Column.groupId.rawValue, .blob).notNull()
                table.column(GroupMessage.Column.sender.rawValue, .blob).notNull()
                table.column(GroupMessage.Column.roundURL.rawValue, .text)
                table.column(GroupMessage.Column.payload.rawValue, .text).notNull()
                table.column(GroupMessage.Column.status.rawValue, .integer).notNull()
                table.column(GroupMessage.Column.unread.rawValue, .boolean).notNull()
                table.column(GroupMessage.Column.timestamp.rawValue, .integer).notNull()
            }

            try db.create(table: FileTransfer.databaseTableName, ifNotExists: true) { table in
                table.autoIncrementedPrimaryKey(FileTransfer.Column.id.rawValue, onConflict: .replace)
                table.column(FileTransfer.Column.tid.rawValue, .blob).notNull()
                table.column(FileTransfer.Column.contact.rawValue, .blob).notNull()
                table.column(FileTransfer.Column.fileName.rawValue, .text).notNull()
                table.column(FileTransfer.Column.fileType.rawValue, .text).notNull()
                table.column(FileTransfer.Column.isIncoming.rawValue, .boolean).notNull()
            }
        }
    }
}
