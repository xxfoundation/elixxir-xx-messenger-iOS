import Shared
import AppCore
import XXModels
import XXClient
import Foundation
import XXMessengerClient

extension LaunchViewModel {
  func generateGroupManager() throws {
    groupManager.set(try NewGroupChat.live(
      e2eId: messenger.e2e()!.getId(),
      groupRequest: .init(handle: { [weak self] group in
        guard let self else { return }
        self.handleGroupRequest(from: group, messenger: self.messenger)
      }),
      groupChatProcessor: .init(handle: { [weak self] result in
        guard let self else { return }

        switch result {
        case .success(let cb):
          do {
            let payload = try MessagePayload.decode(cb.decryptedMessage.payload)

            try self.dbManager.getDB().saveMessage(
              .init(
                networkId: cb.decryptedMessage.messageId,
                senderId: cb.decryptedMessage.senderId,
                recipientId: nil,
                groupId: cb.decryptedMessage.groupId,
                date: Date.fromTimestamp(Int(cb.decryptedMessage.timestamp)),
                status: .received,
                isUnread: true,
                text: payload.text,
                replyMessageId: payload.replyingTo,
                roundURL: cb.roundUrl
              )
            )
          } catch {
            print(error.localizedDescription)
          }
        case .failure(let error):
          print(error.localizedDescription)
        }
      })
    ))
  }

  func handleGroupRequest(from group: XXClient.Group, messenger: Messenger) {
    if let _ = try? dbManager.getDB().fetchGroups(.init(id: [group.getId()])).first { return }

    guard var members = try? group.getMembership(), let leader = members.first else {
      fatalError("Failed to get group membership/leader")
    }

    try! dbManager.getDB().saveGroup(.init(
      id: group.getId(),
      name: String(data: group.getName(), encoding: .utf8)!,
      leaderId: leader.id,
      createdAt: Date.fromMSTimestamp(group.getCreatedMS()),
      authStatus: .pending,
      serialized: group.serialize()
    ))

    if let initMessageData = group.getInitMessage(),
       let initMessage = String(data: initMessageData, encoding: .utf8) {
      try! dbManager.getDB().saveMessage(.init(
        senderId: leader.id,
        recipientId: nil,
        groupId: group.getId(),
        date: Date.fromMSTimestamp(group.getCreatedMS()),
        status: .received,
        isUnread: true,
        text: initMessage
      ))
    }

    let friends = try! dbManager.getDB().fetchContacts(.init(
      id: Set(members.map(\.id)),
      authStatus: [
        .friend,
        .hidden,
        .requesting,
        .confirming,
        .verificationInProgress,
        .verified,
        .requested,
        .requestFailed,
        .verificationFailed,
        .confirmationFailed
      ]
    ))

    let strangers = Set(members.map(\.id)).subtracting(Set(friends.map(\.id)))

    strangers.forEach {
      if let stranger = try? dbManager.getDB().fetchContacts(.init(id: [$0])).first {
        print(">>> This is a stranger, but I already knew about his/her existance: \(stranger.id.base64EncodedString().prefix(10))...")
      } else {
        try! dbManager.getDB().saveContact(.init(
          id: $0,
          marshaled: nil,
          username: "Fetching...",
          email: nil,
          phone: nil,
          nickname: nil,
          photo: nil,
          authStatus: .stranger,
          isRecent: false,
          isBlocked: false,
          isBanned: false,
          createdAt: Date.fromMSTimestamp(group.getCreatedMS())
        ))
      }
    }

    members.forEach {
      let model = XXModels.GroupMember(groupId: group.getId(), contactId: $0.id)
      _ = try? dbManager.getDB().saveGroupMember(model)
    }

    do {
      let multiLookup = try messenger.lookupContacts(ids: strangers.map { $0 })

      for user in multiLookup.contacts {
        if var foo = try? self.dbManager.getDB().fetchContacts(.init(id: [user.getId()])).first,
           let username = try? user.getFact(.username)?.value {
          foo.username = username
          _ = try? self.dbManager.getDB().saveContact(foo)
        }
      }
    } catch {
      // TODO
    }
  }
}



//func handleIncomingTransfer(_ receivedFile: ReceivedFile) {
//  if var model = try? dbManager.getDB().saveFileTransfer(.init(
//    id: receivedFile.transferId,
//    contactId: receivedFile.senderId,
//    name: receivedFile.name,
//    type: receivedFile.type,
//    data: nil,
//    progress: 0.0,
//    isIncoming: true,
//    createdAt: Date()
//  )) {
//    try! dbManager.getDB().saveMessage(.init(
//      networkId: nil,
//      senderId: receivedFile.senderId,
//      recipientId: messenger.e2e.get()!.getContact().getId(),
//      groupId: nil,
//      date: Date(),
//      status: .receiving,
//      isUnread: false,
//      text: "",
//      replyMessageId: nil,
//      roundURL: nil,
//      fileTransferId: model.id
//    ))
//
//    if let manager: XXClient.FileTransfer = try? DI.Container.shared.resolve() {
//      print(">>> registerReceivedProgressCallback")
//
//      try! manager.registerReceivedProgressCallback(
//        transferId: receivedFile.transferId,
//        period: 1_000,
//        callback: .init(handle: { [weak self] in
//          guard let self else { return }
//          switch $0 {
//          case .success(let cb):
//            if cb.progress.completed {
//              model.progress = 100
//              model.data = try! manager.receive(transferId: receivedFile.transferId)
//            } else {
//              model.progress = Float(cb.progress.transmitted/cb.progress.total)
//            }
//
//            model = try! self.dbManager.getDB().saveFileTransfer(model)
//
//          case .failure(let error):
//            print(error.localizedDescription)
//          }
//        })
//      )
//    } else {
//      //print(DI.Container.shared.dependencies)
//    }
//  }
//}
