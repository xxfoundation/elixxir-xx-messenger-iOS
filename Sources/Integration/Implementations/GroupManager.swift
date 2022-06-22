import Models
import XXModels
import Bindings

extension BindingsGroupChat: GroupManagerInterface {
    public func send(_ payload: Data, to group: Data) -> Result<(Int64, Data?, String), Error> {
        log(type: .crumbs)

        do {
            let report = try send(group, message: payload)
            return .success((
                report.getRoundID(),
                report.getMessageID(),
                report.getRoundURL()
            ))
        } catch {
            return .failure(error)
        }
    }

    public func create(
        me: Data,
        name: String,
        welcome: String?,
        with ids: [Data],
        _ completion: @escaping (Result<Group, Error>) -> Void
    ) {
        log(type: .crumbs)

        let list = BindingsIdList()
        ids.forEach { try? list.add($0) }

        var welcomeData: Data?

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            if let welcome = welcome {
                welcomeData = welcome.data(using: .utf8)
            }

            let report = self.makeGroup(list, name: name.data(using: .utf8), message: welcomeData)

            if let status = report?.getStatus() {
                switch status {
                case 0:
                    completion(.failure(NSError.create("An error occurred before any requests could be sent")))
                    return
                case 1, 2:
                    // 1. All requests failed to send
                    // 2. Some requests failed and some succeeded

                    if let id = report?.getGroup()?.getID() {
                        do {
                            try self.resendRequest(id)
                            fallthrough
                        } catch {
                            completion(.failure(error))
                            return
                        }
                    }
                case 3:
                    // All good
                    guard let group = report?.getGroup() else {
                        let errorContent = "Couldn't get report from group, although status was 3."
                        completion(.failure(NSError.create(errorContent)))
                        log(string: errorContent, type: .error)
                        return
                    }

                    completion(.success(
                        .init(
                            leader: me,
                            name: name,
                            groupId: group.getID()!,
                            status: .participating,
                            createdAt: Date(),
                            serialize: group.serialize()!
                        )))
                    return
                default:
                    break
                }
            }
        }
    }

    public func join(_ serializedGroup: Data) throws {
        try joinGroup(serializedGroup)
    }

    public func leave(_ groupId: Data) throws {
        try leaveGroup(groupId)
    }
}
