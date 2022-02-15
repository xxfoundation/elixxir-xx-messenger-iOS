import Models
import Foundation

public typealias GroupCompletion = (Result<(Group, [GroupMember]), Error>) -> Void

extension Session {
    public func join(group: Group) throws {
        guard let manager = client.groupManager else { fatalError("A group manager was not created") }

        try manager.join(group.serialize)
        var group = group
        group.accepted = true
        scanStrangers()
        try dbManager.save(group)
    }

    public func leave(group: Group) throws {
        guard let manager = client.groupManager else { fatalError("A group manager was not created") }
        try manager.leave(group.groupId)
        try dbManager.delete(group)
    }

    public func createGroup(name: String, welcome: String?, members: [Contact], _ completion: @escaping GroupCompletion) {
        guard let manager = client.groupManager else { fatalError("A group manager was not created") }

        let me = client.bindings.meMarshalled
        let memberIds = members.map { $0.userId }

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
        try! dbManager.save(group)

        if let welcome = welcome {
            try! dbManager.save(GroupMessage(group: group, text: welcome, me: client.bindings.meMarshalled))
        }

        var members: [GroupMember] = []

        if let contactsOnGroup: [Contact] = try? dbManager.fetch(.withUserIds(memberIds)) {
            contactsOnGroup.forEach { members.append(GroupMember(contact: $0, group: group)) }
        }

        let strangersOnGroup = memberIds
            .filter { !members.map { $0.userId }.contains($0) }
            .filter { $0 != client.bindings.myId }

        if !strangersOnGroup.isEmpty {
            for stranger in strangersOnGroup.enumerated() {
                members.append(GroupMember(
                    userId: stranger.element,
                    groupId: group.groupId,
                    status: .pendingUsername,
                    username: "Unknown user nº \(stranger.offset)",
                    photo: nil
                ))
            }
        }

        members.forEach { try! dbManager.save($0) }

        if group.leader != client.bindings.meMarshalled, inappnotifications {
            DeviceFeedback.sound(.contactAdded)
            DeviceFeedback.shake(.notification)
        }

        scanStrangers()
        return members
    }
}

// MARK: - GroupMessages

extension Session {
    public func delete(groupMessages: [Int64]) {
        groupMessages.forEach {
            do {
                try dbManager.delete(GroupMessage.self, .id($0))
            } catch {
                log(string: error.localizedDescription, type: .error)
            }
        }
    }

    public func send(_ payload: Payload, toGroup group: Group) {
        var groupMessage = GroupMessage(
            sender: client.bindings.meMarshalled,
            groupId: group.groupId,
            payload: payload,
            unread: false,
            timestamp: Date.asTimestamp,
            uniqueId: nil,
            status: .sending
        )

        do {
            groupMessage = try dbManager.save(groupMessage)
            send(groupMessage: groupMessage)
        } catch {
            log(string: error.localizedDescription, type: .error)
        }
    }

    public func retryGroupMessage(_ id: Int64) {
        guard var message: GroupMessage = try? dbManager.fetch(withId: id) else { return }
        message.timestamp = Date.asTimestamp
        message.status = .sending
        send(groupMessage: try! dbManager.save(message))
    }

    private func send(groupMessage: GroupMessage) {
        guard let manager = client.groupManager else { fatalError("A group manager was not created") }
        var groupMessage = groupMessage

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            switch manager.send(groupMessage.payload.asData(), to: groupMessage.groupId) {
            case .success((let roundId, let uniqueId, let roundURL)):
                groupMessage.roundURL = roundURL

                self.client.bindings.listenRound(id: Int(roundId)) { result in
                    switch result {
                    case .success(let succeeded):
                        groupMessage.uniqueId = uniqueId
                        groupMessage.status = succeeded ? .sent : .failed
                    case .failure:
                        groupMessage.status = .failed
                    }

                    do {
                        try self.dbManager.save(groupMessage)
                    } catch {
                        log(string: error.localizedDescription, type: .error)
                    }
                }
            case .failure:
                groupMessage.status = .failed
            }

            do {
                try self.dbManager.save(groupMessage)
            } catch {
                log(string: error.localizedDescription, type: .error)
            }
        }
    }

    private func scanStrangers() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let ud = self.client.userDiscovery else { return }

            guard let strangers: [GroupMember] = try? self.dbManager.fetch(.strangers) else { return }
            let ids = strangers.map { $0.userId }

            var updatedStrangers: [GroupMember] = []

            ud.lookup(idList: ids) {
                switch $0 {
                case .success(let result):
                    strangers.forEach { stranger in
                        if let found = result.first(where: { lookup in lookup.id == stranger.userId }) {
                            var updatedStranger = stranger
                            updatedStranger.username = found.username
                            updatedStrangers.append(updatedStranger)
                        }
                    }

                    DispatchQueue.main.async {
                        updatedStrangers.forEach {

                            do {
                                try self.dbManager.save($0)
                            } catch {
                                log(string: error.localizedDescription, type:.error)
                            }
                        }

                        log(string: "Scanned unknown group members", type: .info)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        log(string: error.localizedDescription, type: .error)
                    }
                }
            }
        }
    }
}

private extension GroupMessage {
    init(group: Group, text: String, me: Data) {
        self.init(
            sender: group.leader,
            groupId: group.groupId,
            payload: .init(text: text, reply: nil, attachment: nil),
            unread: false,
            timestamp: Date.asTimestamp,
            uniqueId: nil,
            status: group.leader == me ? .sent : .received
        )
    }
}

private extension GroupMember {
    init(contact: Contact, group: Group) {
        self.init(
            userId: contact.userId,
            groupId: group.groupId,
            status: .usernameSet,
            username: contact.username,
            photo: contact.photo
        )
    }
}
