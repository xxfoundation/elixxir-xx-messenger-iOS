import Shared
import XXClient
import XXModels
import XXLogger
import Foundation
import XXMessengerClient
import DependencyInjection

extension LaunchViewModel {
  func setupBackupCallback() {
    backupCallbackCancellable = messenger.registerBackupCallback(.init(handle: { [weak self] in
      print(">>> Backup callback from bindings got called")
      self?.backupService.updateLocalBackup($0)
    }))
  }

  func setupMessageCallback() {
    messageListenerCallbacksCancellable = messenger.registerMessageListener(.init(handle: {
      guard let payload = try? Payload(with: $0.payload) else {
        fatalError("Couldn't decode payload: \(String(data: $0.payload, encoding: .utf8) ?? "nil")")
      }

      try! self.database.saveMessage(.init(
        networkId: $0.id,
        senderId: $0.sender,
        recipientId: self.messenger.e2e.get()!.getContact().getId(),
        groupId: nil,
        date: Date.fromTimestamp($0.timestamp),
        status: .received,
        isUnread: true,
        text: payload.text,
        replyMessageId: payload.reply?.messageId,
        roundURL: $0.roundURL,
        fileTransferId: nil
      ))

      if var contact = try? self.database.fetchContacts(.init(id: [$0.sender])).first {
        contact.isRecent = false
        try! self.database.saveContact(contact)
      }
    }))
  }

  func setupAuthCallback() {
    authCallbacksCancellable = messenger.registerAuthCallbacks(
      AuthCallbacks(handle: {
        switch $0 {
        case .confirm(contact: let contact, receptionId: _, ephemeralId: _, roundId: _):
          self.handleConfirm(from: contact)
        case .request(contact: let contact, receptionId: _, ephemeralId: _, roundId: _):
          self.handleDirectRequest(from: contact)
        case .reset(contact: let contact, receptionId: _, ephemeralId: _, roundId: _):
          self.handleReset(from: contact)
        }
      })
    )
  }

  func handleReset(from user: XXClient.Contact) {
    if var contact = try? database.fetchContacts(.init(id: [user.getId()])).first {
      contact.authStatus = .friend
      _ = try? database.saveContact(contact)
    }
  }

  func handleConfirm(from contact: XXClient.Contact) {
    guard let id = try? contact.getId() else {
      fatalError("Couldn't extract ID from contact confirmation arrived.")
    }

    guard var existentContact = try? database.fetchContacts(.init(id: [id])).first else {
      print(">>> Tried to handle a confirmation from someone that is not a contact yet")
      return
    }

    existentContact.isRecent = true
    existentContact.authStatus = .friend
    try! database.saveContact(existentContact)
  }

  func setupLogWriter() {
    _ = try! SetLogLevel.live(.fatal)
    RegisterLogWriter.live(.init(handle: { XXLogger.live().debug($0) }))
  }

  func listenToNetworkUpdates() {
    networkMonitor.start()
    networkCallbacksCancellable = messenger.cMix.get()!.addHealthCallback(.init(handle: { [weak self] in
      guard let self else { return }
      self.networkMonitor.update($0)
    }))
  }

  func handleIncomingTransfer(_ receivedFile: ReceivedFile) {
    //    if var model = try? database.saveFileTransfer(.init(
    //      id: receivedFile.transferId,
    //      contactId: receivedFile.senderId,
    //      name: receivedFile.name,
    //      type: receivedFile.type,
    //      data: nil,
    //      progress: 0.0,
    //      isIncoming: true,
    //      createdAt: Date()
    //    )) {
    //      try! database.saveMessage(.init(
    //        networkId: nil,
    //        senderId: receivedFile.senderId,
    //        recipientId: messenger.e2e.get()!.getContact().getId(),
    //        groupId: nil,
    //        date: Date(),
    //        status: .receiving,
    //        isUnread: false,
    //        text: "",
    //        replyMessageId: nil,
    //        roundURL: nil,
    //        fileTransferId: model.id
    //      ))
    //
    //      if let manager: XXClient.FileTransfer = try? DependencyInjection.Container.shared.resolve() {
    //        print(">>> registerReceivedProgressCallback")
    //
    //        try! manager.registerReceivedProgressCallback(
    //          transferId: receivedFile.transferId,
    //          period: 1_000,
    //          callback: .init(handle: { [weak self] in
    //            guard let self else { return }
    //            switch $0 {
    //            case .success(let cb):
    //              if cb.progress.completed {
    //                model.progress = 100
    //                model.data = try! manager.receive(transferId: receivedFile.transferId)
    //              } else {
    //                model.progress = Float(cb.progress.transmitted/cb.progress.total)
    //              }
    //
    //              model = try! self.database.saveFileTransfer(model)
    //
    //            case .failure(let error):
    //              print(error.localizedDescription)
    //            }
    //          })
    //        )
    //      } else {
    //        //print(DependencyInjection.Container.shared.dependencies)
    //      }
    //    }
  }

  func handleDirectRequest(from contact: XXClient.Contact) {
    guard let id = try? contact.getId() else {
      fatalError("Couldn't extract ID from contact request arrived.")
    }

    if let _ = try? database.fetchContacts(.init(id: [id])).first {
      print(">>> Tried to handle request from pre-existing contact.")
      return
    }

    let facts = try? contact.getFacts()
    let email = facts?.first(where: { $0.type == .email })?.value
    let phone = facts?.first(where: { $0.type == .phone })?.value
    let username = facts?.first(where: { $0.type == .username })?.value

    var model = try! database.saveContact(.init(
      id: id,
      marshaled: contact.data,
      username: username,
      email: email,
      phone: phone,
      nickname: nil,
      photo: nil,
      authStatus: .verificationInProgress,
      isRecent: true,
      createdAt: Date()
    ))

    do {
      let messenger: Messenger = try DependencyInjection.Container.shared.resolve()
      try messenger.waitForNetwork()

      if try messenger.verifyContact(contact) {
        print(">>> [messenger.verifyContact \(#file):\(#line)]")

        model.authStatus = .verified
        model = try database.saveContact(model)
      } else {
        print(">>> [messenger.verifyContact \(#file):\(#line)]")
        try database.deleteContact(model)
      }
    } catch {
      print(">>> [messenger.verifyContact] thrown an exception: \(error.localizedDescription)")

      model.authStatus = .verificationFailed
      model = try! database.saveContact(model)
    }
  }

  func handleGroupRequest(from group: XXClient.Group, messenger: Messenger) {
    if let _ = try? database.fetchGroups(.init(id: [group.getId()])).first {
      print(">>> Tried to handle a group request that is already handled")
      return
    }

    guard var members = try? group.getMembership(), let leader = members.first else {
      fatalError("Failed to get group membership/leader")
    }

    try! database.saveGroup(.init(
      id: group.getId(),
      name: String(data: group.getName(), encoding: .utf8)!,
      leaderId: leader.id,
      createdAt: Date.fromMSTimestamp(group.getCreatedMS()),
      authStatus: .pending,
      serialized: group.serialize()
    ))

    if let initMessageData = group.getInitMessage(),
       let initMessage = String(data: initMessageData, encoding: .utf8) {
      try! database.saveMessage(.init(
        senderId: leader.id,
        recipientId: nil,
        groupId: group.getId(),
        date: Date.fromMSTimestamp(group.getCreatedMS()),
        status: .received,
        isUnread: true,
        text: initMessage
      ))
    }

    print(">>> All members in the arrived group request:")
    members.forEach { print(">>> \($0.id.base64EncodedString().prefix(10))...") }
    print(">>> My ud.id is: \(try! messenger.ud.get()!.getContact().getId().base64EncodedString().prefix(10))...")
    print(">>> My e2e.id is: \(try! messenger.e2e.get()!.getContact().getId().base64EncodedString().prefix(10))...")

    let friends = try! database.fetchContacts(.init(
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

    print(">>> These people I already know:")
    friends.forEach {
      print(">>> Username: \($0.username), authStatus: \($0.authStatus.rawValue), id: \($0.id.base64EncodedString().prefix(10))...")
    }

    let strangers = Set(members.map(\.id)).subtracting(Set(friends.map(\.id)))

    strangers.forEach {
      if let stranger = try? database.fetchContacts(.init(id: [$0])).first {
        print(">>> This is a stranger, but I already knew about his/her existance: \(stranger.id.base64EncodedString().prefix(10))...")
      } else {
        print(">>> This is a complete stranger. Storing on the db: \($0.base64EncodedString().prefix(10))...")

        try! database.saveContact(.init(
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
      _ = try? database.saveGroupMember(model)
    }

    print(">>> Performing a multi-lookup for group strangers:")

    do {
      let multiLookup = try messenger.lookupContacts(ids: strangers.map { $0 })

      for user in multiLookup.contacts {
        print(">>> Found stranger w/ id: \(try! user.getId().base64EncodedString().prefix(10))...")

        if var foo = try? self.database.fetchContacts(.init(id: [user.getId()])).first,
           let username = try? user.getFact(.username)?.value {
          foo.username = username
          print(">>> Set username: \(username) for \(try! user.getId().base64EncodedString().prefix(10))...")
          _ = try? self.database.saveContact(foo)
        }
      }

      for error in multiLookup.errors {
        print(">>> Failure on Multilookup: \(error.localizedDescription)")
      }

      for failedId in multiLookup.failedIds {
        print(">>> Failed id: \(failedId.base64EncodedString().prefix(10))...")
      }
    } catch {
      print(">>> Exception on multilookup: \(error.localizedDescription)")
    }
  }

  func generateGroupManager() throws {
    let manager = try NewGroupChat.live(
      e2eId: messenger.e2e()!.getId(),
      groupRequest: .init(handle: { [weak self] group in
        guard let self else { return }
        self.handleGroupRequest(from: group, messenger: self.messenger)
      }),
      groupChatProcessor: .init(handle: { result in
        switch result {
        case .success(let cb):

          print("Incoming GroupMessage:")
          print("- groupId: \(cb.decryptedMessage.groupId.base64EncodedString().prefix(10))...")
          print("- senderId: \(cb.decryptedMessage.senderId.base64EncodedString().prefix(10))...")
          print("- messageId: \(cb.decryptedMessage.messageId.base64EncodedString().prefix(10))...")

          if let payload = try? Payload(with: cb.decryptedMessage.payload) {
            print("- payload.text: \(payload.text)")

            if let reply = payload.reply {
              print("- payload.reply.senderId: \(reply.senderId.base64EncodedString().prefix(10))...")
              print("- payload.reply.messageId: \(reply.messageId.base64EncodedString().prefix(10))...")
            } else {
              print("- payload.reply: ∅")
            }
          }
          print("")

          guard let payload = try? Payload(with: cb.decryptedMessage.payload) else {
            fatalError("Couldn't decode payload: \(String(data: cb.decryptedMessage.payload, encoding: .utf8) ?? "nil")")
          }

          let msg = Message(
            networkId: cb.decryptedMessage.messageId,
            senderId: cb.decryptedMessage.senderId,
            recipientId: nil,
            groupId: cb.decryptedMessage.groupId,
            date: Date.fromTimestamp(Int(cb.decryptedMessage.timestamp)),
            status: .received,
            isUnread: true,
            text: payload.text,
            replyMessageId: payload.reply?.messageId,
            roundURL: "https://google.com.br",
            fileTransferId: nil
          )

          _ = try? self.database.saveMessage(msg)

        case .failure(let error):
          break
        }
      })
    )

    DependencyInjection.Container.shared.register(manager)
  }

  func generateTransferManager() throws {
    //    let manager = try InitFileTransfer.live(
    //      e2eId: messenger.e2e()!.getId(),
    //      callback: .init(handle: { [weak self] in
    //        guard let self else { return }
    //
    //        switch $0 {
    //        case .success(let receivedFile):
    //          self.handleIncomingTransfer(receivedFile, messenger: messenger)
    //        case .failure(let error):
    //          print(error.localizedDescription)
    //        }
    //      })
    //    )
    //
    //    DependencyInjection.Container.shared.register(manager)
  }

  func generateTrafficManager() throws {
    let manager = try NewDummyTrafficManager.live(
      cMixId: messenger.e2e()!.getId()
    )

    DependencyInjection.Container.shared.register(manager)
    try! manager.setStatus(dummyTrafficOn)
  }

  func setupMessenger() throws {
    setupLogWriter()
    setupAuthCallback()
    setupBackupCallback()
    setupMessageCallback()

    if messenger.isLoaded() == false {
      if messenger.isCreated() == false {
        try messenger.create()
      }

      try messenger.load()
    }

    try messenger.start()

    if messenger.isConnected() == false {
      try messenger.connect()
      try messenger.listenForMessages()
    }

    try generateGroupManager()
    try generateTrafficManager()
    try generateTransferManager()
    listenToNetworkUpdates()

    if messenger.isLoggedIn() == false {
      if try messenger.isRegistered() {
        try messenger.logIn()
        hudController.dismiss()
        stateSubject.value.shouldPushChats = true
      } else {
        try? sftpManager.unlink()
        try? dropboxManager.unlink()
        hudController.dismiss()
        stateSubject.value.shouldPushOnboarding = true
      }
    } else {
      hudController.dismiss()
      stateSubject.value.shouldPushChats = true
    }
    if !messenger.isBackupRunning() {
      try? messenger.resumeBackup()
    }
    // TODO: Biometric auth
  }
}
