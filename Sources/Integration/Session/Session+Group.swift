import Models
import XXModels
import Foundation

extension Session {
    public func join(group: Group) throws {
        guard let manager = client.groupManager else { fatalError("A group manager was not created") }

        try manager.join(group.serialized)
        var group = group
        group.authStatus = .participating
        scanStrangers {}
        try dbManager.saveGroup(group)
    }

    public func leave(group: Group) throws {
        guard let manager = client.groupManager else { fatalError("A group manager was not created") }
        try manager.leave(group.id)
        try dbManager.deleteGroup(group)
    }

    public func createGroup(
        name: String,
        welcome: String?,
        members: [Contact],
        _ completion: @escaping (Result<GroupInfo, Error>) -> Void
    ) {
        guard let manager = client.groupManager else { fatalError("A group manager was not created") }

        let me = client.bindings.meMarshalled
        let memberIds = members.map { $0.id }

        manager.create(me: me, name: name, welcome: welcome, with: memberIds) { [weak self] in
            guard let self = self else { return }

            switch $0 {
            case .success(let group):
                completion(.success(self.processGroupCreation(group, memberIds: memberIds, welcome: welcome)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    @discardableResult
    func processGroupCreation(_ group: Group, memberIds: [Data], welcome: String?) -> GroupInfo {
        /// Save the group
        ///
        _ = try? dbManager.saveGroup(group)

        /// Save the members
        ///
        memberIds.forEach { _ = try? dbManager.saveGroupMember(.init(groupId: group.id, contactId: $0)) }

        /// Save the welcome message (if any)
        ///
        if let welcome = welcome {
            _ = try? dbManager.saveMessage(.init(
                networkId: nil,
                senderId: group.leaderId,
                recipientId: client.bindings.myId,
                groupId: group.id,
                date: Date(),
                status: .received,
                isUnread: true,
                text: welcome,
                replyMessageId: nil,
                roundURL: nil,
                fileTransferId: nil
            ))
        }

        /// Buzz if the group was not created by me
        ///
        if group.leaderId != client.bindings.myId, inappnotifications {
            DeviceFeedback.sound(.contactAdded)
            DeviceFeedback.shake(.notification)
        }

        scanStrangers {}

        guard let info = try? dbManager.fetchGroupInfos(.init(groupId: group.id)).first else {
            fatalError()
        }

        return info
    }
}

// MARK: - GroupMessages

extension Session {
    public func send(_ payload: Payload, toGroup group: Group) {
        var message = Message(
            senderId: client.bindings.myId,
            recipientId: nil,
            groupId: group.id,
            date: Date(),
            status: .sending,
            isUnread: false,
            text: payload.text,
            replyMessageId: payload.reply?.messageId,
            roundURL: nil,
            fileTransferId: nil
        )

        do {
            message = try dbManager.saveMessage(message)
            send(message: message)
        } catch {
            log(string: error.localizedDescription, type: .error)
        }
    }

    private func send(message: Message) {
        guard let manager = client.groupManager else { fatalError("A group manager was not created") }
        var message = message

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            switch manager.send(message.text.data(using: .utf8)!, to: message.groupId!) {
            case .success((let roundId, let uniqueId, let roundURL)):
                message.roundURL = roundURL

                self.client.bindings.listenRound(id: Int(roundId)) { result in
                    switch result {
                    case .success(let succeeded):
                        message.networkId = uniqueId
                        message.status = succeeded ? .sent : .sendingFailed
                    case .failure:
                        message.status = .sendingFailed
                    }

                    do {
                        try self.dbManager.saveMessage(message)
                    } catch {
                        log(string: error.localizedDescription, type: .error)
                    }
                }
            case .failure:
                message.status = .sendingFailed
            }

            do {
                try self.dbManager.saveMessage(message)
            } catch {
                log(string: error.localizedDescription, type: .error)
            }
        }
    }

    public func scanStrangers(_ completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let ud = self.client.userDiscovery,
                  let strangers = try? self.dbManager.fetchContacts(.init(username: .some(nil))),
                  !strangers.isEmpty else { return }

            ud.lookup(idList: strangers.map(\.id)) { result in
                switch result {
                case .success(let strangersWithUsernames):
                    let acquaintances = strangers.map { stranger -> Contact in
                        var exStranger = stranger
                        exStranger.username = strangersWithUsernames.first(where: { $0.id == stranger.id })?.username
                        return exStranger
                    }

                    DispatchQueue.main.async {
                        acquaintances.forEach { _ = try? self.dbManager.saveContact($0) }
                    }

                    completion()
                case .failure(let error):
                    print(error.localizedDescription)
                    DispatchQueue.main.async { completion() }
                }
            }
        }
    }
}
