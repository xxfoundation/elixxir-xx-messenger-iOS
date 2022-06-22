import Models
import XXModels
import Foundation

public typealias GroupCompletion = (Result<(Group, [GroupMember]), Error>) -> Void

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

    public func createGroup(name: String, welcome: String?, members: [Contact], _ completion: @escaping GroupCompletion) {
        guard let manager = client.groupManager else { fatalError("A group manager was not created") }

        let me = client.bindings.meMarshalled
        let memberIds = members.map { $0.id }

        manager.create(me: me, name: name, welcome: welcome, with: memberIds) { [weak self] in
            guard let self = self else { return }

            switch $0 {
            case .success(let group):
                completion(.success((group, self.processGroupCreation(group, memberIds: memberIds, welcome: welcome))))
                break
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    @discardableResult
    func processGroupCreation(_ group: Group, memberIds: [Data], welcome: String?) -> [GroupMember] {
        // TODO: Implement this checking on which members of the group are my members etc.

//        try! dbManager.saveGroup(group)
//
//        var members: [GroupMember] = []
//
//        if let contactsOnGroup: [Contact] = try? dbManager.fetchContacts(.init(id: Set(memberIds)) {
//            //contactsOnGroup.forEach { members.append(GroupMember(contact: $0, group: group)) }
//        }
//
//        let strangersOnGroup = memberIds
//            .filter { !members.map { $0.contactId }.contains($0) }
//            .filter { $0 != client.bindings.myId }
//
//        if !strangersOnGroup.isEmpty {
//            for stranger in strangersOnGroup.enumerated() {
//                members.append(GroupMember(
//                    userId: stranger.element,
//                    groupId: group.groupId,
//                    status: .pendingUsername,
//                    username: "Fetching username...",
//                    photo: nil
//                ))
//            }
//        }
//
//        members.forEach { try! dbManager.saveGroupMember($0) }
//
//        if group.leaderId != client.bindings.meMarshalled, inappnotifications {
//            DeviceFeedback.sound(.contactAdded)
//            DeviceFeedback.shake(.notification)
//        }
//
//        scanStrangers {}
//
//        if let welcome = welcome {
//            _ = try? dbManager.saveMessage(.init(
//                networkId: nil,
//                senderId: group.leaderId,
//                recipientId: client.bindings.meMarshalled,
//                groupId: group.id,
//                date: Date(),
//                status: .received,
//                isUnread: true,
//                text: welcome,
//                replyMessageId: nil,
//                roundURL: nil,
//                fileTransferId: nil
//            ))
//        }
//
//        return members
        fatalError()
    }
}

// MARK: - GroupMessages

extension Session {
    public func send(_ payload: Payload, toGroup group: Group) {
        var message = Message(
            senderId: client.bindings.meMarshalled,
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
        // TODO: How this will work?

//        DispatchQueue.global().async { [weak self] in
//            guard let self = self, let ud = self.client.userDiscovery else { return }
//
//            guard let strangers = try? self.dbManager.fetchContacts(.init(authStatus: [.stranger])),
//                    strangers.isEmpty == false else {
//                DispatchQueue.main.async { completion() }
//                return
//            }
//
//            let ids = strangers.map { $0.id }
//
//            var updatedStrangers: [GroupMember] = []
//
//            ud.lookup(idList: ids) {
//                switch $0 {
//                case .success(let contacts):
//                    strangers.forEach { stranger in
//                        if let found = contacts.first(where: { contact in contact.id == stranger.id }) {
//                            var updatedStranger = stranger
//                            updatedStranger.username = found.username
//                            updatedStrangers.append(updatedStranger)
//                        }
//                    }
//
//                    DispatchQueue.main.async {
//                        updatedStrangers.forEach {
//                            do {
//                                try self.dbManager.saveContact($0)
//                            } catch {
//                                log(string: error.localizedDescription, type:.error)
//                            }
//                        }
//
//                        log(string: "Scanned unknown group members", type: .info)
//                        completion()
//                    }
//                case .failure(let error):
//                    DispatchQueue.main.async {
//                        log(string: error.localizedDescription, type: .error)
//                        completion()
//                    }
//                }
//            }
//        }
    }
}
