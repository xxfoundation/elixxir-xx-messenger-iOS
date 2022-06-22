import Models
import Shared
import os.log
import Combine
import XXModels
import Bindings
import Foundation

public extension BindingsClient {
    static func listenLogs() {
        let callback = LogCallback { log(string: $0 ?? "", type: .bindings) }
        BindingsRegisterLogWriter(callback)
    }

    func listenPreImageUpdates() {
        let callback = PreImageCallback { [weak self] _, _ in
            if let defaults = UserDefaults(suiteName: "group.elixxir.messenger") {
                let preImage = self?.getPreImages()
                defaults.set(preImage, forKey: "preImage")
            }
        }

        registerPreimageCallback(receptionId, pin: callback)
    }

    func initializeBackup(passphrase: String, callback: @escaping (Data) -> Void) -> BackupInterface {
        var error: NSError?
        os_signpost(.begin, log: logHandler, name: "Encrypting", "Calling BindingsInitializeBackup")
        let backup = BindingsInitializeBackup(passphrase, UpdateBackupCallback(callback), self, &error)
        os_signpost(.end, log: logHandler, name: "Encrypting", "Finished BindingsInitializeBackup")
        return backup!
    }

    func resumeBackup(callback: @escaping (Data) -> Void) -> BackupInterface {
        var error: NSError?
        let backup = BindingsResumeBackup(UpdateBackupCallback(callback), self, &error)
        return backup!
    }

    func listenMessages(_ callback: @escaping (Message) -> Void) throws {
        let zeroBytes = [UInt8](repeating: 0, count: 33)

        let listener = TextListener { bindingsMessage in
            guard let message = bindingsMessage else { return }
            let domainModel = Message(with: message, meMarshalled: self.meMarshalled)
            callback(domainModel)
        }

        _ = try! registerListener(Data(zeroBytes), msgType: 2, listener: listener)
    }

    func listenRequests(
        _ requests: @escaping (Contact) -> Void,
        _ confirmations: @escaping (Contact) -> Void,
        _ resets: @escaping (Contact) -> Void
    ) {
        let resetCallback = ResetCallback { resets(Contact(with: $0, status: .friend)) }
        let confirmCallback = ConfirmationCallback { confirmations(Contact(with: $0, status: .friend)) }
        let requestCallback = RequestCallback { requests(Contact(with: $0, status: .verificationInProgress)) }
        registerAuthCallbacks(requestCallback, confirm: confirmCallback, reset: resetCallback)
    }

    func listenNetworkUpdates(_ callback: @escaping (Bool) -> Void) {
        registerNetworkHealthCB(HealthCallback(callback))
    }

    func listenEvents(_ completion: @escaping (BackendEvent) -> Void) {
        do {
            try registerEventCallback("EventListener", myObj: EventCallback(completion))
        } catch {
            log(string: ">>> Event listener failed: \(error.localizedDescription)", type: .error)
        }
    }

    func listenRound(id: Int, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        let callback = RoundCallback { completion(.success($0)) }
        
        do {
            try wait(forRoundCompletion: id, rec: callback, timeoutMS: 15000)
        } catch {
            completion(.failure(error))
        }
    }

    func listenDelivery(of report: Data, _ completion: @escaping (DeliveryResult) -> Void) throws {
        let callback = DeliveryCallback { completion($0) }

        var roundIds = [Int]()

        var unmarshalError: NSError?

        if let unmarshaled = BindingsUnmarshalSendReport(report, &unmarshalError),
            let roundList = unmarshaled.getRoundList() {
            let length = roundList.len()
            for index in 0..<length {
                var integer: Int = 0
                do {
                    try roundList.get(index, ret0_: &integer)
                    roundIds.append(integer)
                } catch {
                    log(string: ">>> Error inspecting round list:\n\(error.localizedDescription)", type: .error)
                }
            }
        }

        try! wait(forMessageDelivery: report, mdc: callback, timeoutMS: 30000)
    }

    func listenGroupRequests(
        _ groupRequests: @escaping (Group, [Data], String?) -> Void,
        groupMessages: @escaping (Message) -> Void
    ) throws -> GroupManagerInterface? {
        var error: NSError?

        let requestCallback = GroupRequestCallback {
            guard let id = $0.getID(),
                  let name = $0.getName(),
                  let serialize = $0.serialize(),
                  let memberList = $0.getMembership() else { return }

            var members = [Data]()

            var welcomeMessage: String?

            if let welcomeData = $0.getInitMessage() {
                welcomeMessage = String(data: welcomeData, encoding: .utf8)
            }

            for index in 0..<memberList.len() {
                guard let member = try? memberList.get(index),
                      let memberId = member.getID() else { continue }
                members.append(memberId)
            }

            groupRequests(.init(
                id: id,
                name: String(data: name, encoding: .utf8)!,
                leaderId: members.first!,
                createdAt: Date(),
                authStatus: .pending,
                serialized: serialize
            ), members, welcomeMessage)
        }

        let messageCallback = GroupMessageCallback { groupMessages(Message(with: $0)) }
        let groupManager = BindingsNewGroupManager(self, requestCallback, messageCallback, &error)

        guard let error = error else { return groupManager }
        fatalError(error.localizedDescription)
    }
}
