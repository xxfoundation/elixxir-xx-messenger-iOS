import XXModels
import XXClient
import Foundation
import XXMessengerClient
import XCTestDynamicOverlay

public struct GroupRequestHandler {
  public typealias OnError = (Error) -> Void

  public var run: (@escaping OnError) -> Cancellable

  public func callAsFunction(onError: @escaping OnError) -> Cancellable {
    run(onError)
  }
}

extension GroupRequestHandler {
  public static func live(
    messenger: Messenger,
    db: DBManagerGetDB
  ) -> GroupRequestHandler {
    GroupRequestHandler { onError in
      messenger.registerGroupRequestHandler(.init { group in
        do {
          if let _ = try db().fetchGroups(.init(id: [group.getId()])).first {
            return
          }
          guard let leader = try group.getMembership().first else {
            return // Failed to get group membership/leader
          }
          try db().saveGroup(.init(
            id: group.getId(),
            name: String(data: group.getName(), encoding: .utf8)!,
            leaderId: leader.id,
            createdAt: Date.fromMSTimestamp(group.getCreatedMS()),
            authStatus: .pending,
            serialized: group.serialize()
          ))
          if let initialMessageData = group.getInitMessage(),
             let initialMessage = String(data: initialMessageData, encoding: .utf8) {
            try db().saveMessage(.init(
              senderId: leader.id,
              recipientId: nil,
              groupId: group.getId(),
              date: Date.fromMSTimestamp(group.getCreatedMS()),
              status: .received,
              isUnread: true,
              text: initialMessage
            ))
          }
          let members = try group.getMembership()
          let friends = try db().fetchContacts(.init(id: Set(members.map(\.id)), authStatus: [
            .friend, .hidden, .confirming,
            .verified, .requested, .requesting,
            .verificationInProgress, .requestFailed,
            .verificationFailed, .confirmationFailed
          ]))
          let strangers = Set(members.map(\.id)).subtracting(Set(friends.map(\.id)))
          try strangers.forEach {
            if let stranger = try? db().fetchContacts(.init(id: [$0])).first {
              print(stranger)
            } else {
              try db().saveContact(.init(
                id: $0,
                username: "Fetching...",
                authStatus: .stranger,
                isRecent: false,
                isBlocked: false,
                isBanned: false,
                createdAt: Date.fromMSTimestamp(group.getCreatedMS())
              ))
            }
          }
          try members.map {
            XXModels.GroupMember(groupId: group.getId(), contactId: $0.id)
          }.forEach {
            try db().saveGroupMember($0)
          }
          let multilookup = try messenger.lookupContacts(ids: strangers.map { $0 })
          for user in multilookup.contacts {
            if var foo = try? db().fetchContacts(.init(id: [user.getId()])).first,
               let username = try? user.getFact(.username)?.value {
              foo.username = username
              _ = try? db().saveContact(foo)
            }
          }
        } catch {
          onError(error)
        }
      })
    }
  }
}

extension GroupRequestHandler {
  public static let unimplemented = GroupRequestHandler(
    run: XCTUnimplemented("\(Self.self)", placeholder: Cancellable {})
  )
}
