import HUD
import Shared
import Models
import Combine
import Defaults
import XXModels
import XXLogger
import Keychain
import Foundation
import Permissions
import ToastFeature
import DropboxFeature
import VersionChecking
import ReportingFeature
import CombineSchedulers
import DependencyInjection

import XXClient
import struct XXClient.FileTransfer
import class XXClient.Cancellable

import XXDatabase
import XXLegacyDatabaseMigrator
import XXMessengerClient
import NetworkMonitor

struct Update {
    let content: String
    let urlString: String
    let positiveActionTitle: String
    let negativeActionTitle: String?
    let actionStyle: CapsuleButtonStyle
}

enum LaunchRoute {
    case chats
    case update(Update)
    case onboarding
}

final class LaunchViewModel {
    @Dependency var database: Database
    @Dependency var versionChecker: VersionChecker
    @Dependency var dropboxService: DropboxInterface
    @Dependency var fetchBannedList: FetchBannedList
    @Dependency var reportingStatus: ReportingStatus
    @Dependency var toastController: ToastController
    @Dependency var keychainHandler: KeychainHandling
    @Dependency var networkMonitor: NetworkMonitoring
    @Dependency var processBannedList: ProcessBannedList
    @Dependency var permissionHandler: PermissionHandling

    @KeyObject(.username, defaultValue: nil) var username: String?
    @KeyObject(.biometrics, defaultValue: false) var isBiometricsOn: Bool
    @KeyObject(.dummyTrafficOn, defaultValue: false) var dummyTrafficOn: Bool

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var authCallbacksCancellable: Cancellable?

    var routePublisher: AnyPublisher<LaunchRoute, Never> {
        routeSubject.eraseToAnyPublisher()
    }

    var mainScheduler: AnySchedulerOf<DispatchQueue> = {
        DispatchQueue.main.eraseToAnyScheduler()
    }()

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = {
        DispatchQueue.global().eraseToAnyScheduler()
    }()

    private var cancellables = Set<AnyCancellable>()
    private let routeSubject = PassthroughSubject<LaunchRoute, Never>()
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)

    func viewDidAppear() {
        mainScheduler.schedule(after: .init(.now() + 1)) { [weak self] in
            guard let self = self else { return }

            self.hudSubject.send(.on)

            self.versionChecker().sink { [unowned self] in
                switch $0 {
                case .upToDate:
                    self.updateBannedList {
                        self.updateErrors {
                            self.continueWithInitialization()
                        }
                    }
                case .failure(let error):
                    self.versionFailed(error: error)
                case .updateRequired(let info):
                    self.versionUpdateRequired(info)
                case .updateRecommended(let info):
                    self.versionUpdateRecommended(info)
                }
            }.store(in: &self.cancellables)
        }
    }

    func continueWithInitialization() {
        do {
            try self.setupDatabase()

            _ = try SetLogLevel.live(.info)

            RegisterLogWriter.live(.init(handle: {
                XXLogger.live().debug($0)
            }))

            var environment: MessengerEnvironment = .live()
            environment.ndfEnvironment = .mainnet
            environment.udAddress = "46.101.98.49:18001"
            environment.udCert = """
            -----BEGIN CERTIFICATE-----
            MIIDbDCCAlSgAwIBAgIJAOUNtZneIYECMA0GCSqGSIb3DQEBBQUAMGgxCzAJBgNV
            BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlDbGFyZW1vbnQx
            GzAZBgNVBAoMElByaXZhdGVncml0eSBDb3JwLjETMBEGA1UEAwwKKi5jbWl4LnJp
            cDAeFw0xOTAzMDUxODM1NDNaFw0yOTAzMDIxODM1NDNaMGgxCzAJBgNVBAYTAlVT
            MRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlDbGFyZW1vbnQxGzAZBgNV
            BAoMElByaXZhdGVncml0eSBDb3JwLjETMBEGA1UEAwwKKi5jbWl4LnJpcDCCASIw
            DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPP0WyVkfZA/CEd2DgKpcudn0oDh
            Dwsjmx8LBDWsUgQzyLrFiVigfUmUefknUH3dTJjmiJtGqLsayCnWdqWLHPJYvFfs
            WYW0IGF93UG/4N5UAWO4okC3CYgKSi4ekpfw2zgZq0gmbzTnXcHF9gfmQ7jJUKSE
            tJPSNzXq+PZeJTC9zJAb4Lj8QzH18rDM8DaL2y1ns0Y2Hu0edBFn/OqavBJKb/uA
            m3AEjqeOhC7EQUjVamWlTBPt40+B/6aFJX5BYm2JFkRsGBIyBVL46MvC02MgzTT9
            bJIJfwqmBaTruwemNgzGu7Jk03hqqS1TUEvSI6/x8bVoba3orcKkf9HsDjECAwEA
            AaMZMBcwFQYDVR0RBA4wDIIKKi5jbWl4LnJpcDANBgkqhkiG9w0BAQUFAAOCAQEA
            neUocN4AbcQAC1+b3To8u5UGdaGxhcGyZBlAoenRVdjXK3lTjsMdMWb4QctgNfIf
            U/zuUn2mxTmF/ekP0gCCgtleZr9+DYKU5hlXk8K10uKxGD6EvoiXZzlfeUuotgp2
            qvI3ysOm/hvCfyEkqhfHtbxjV7j7v7eQFPbvNaXbLa0yr4C4vMK/Z09Ui9JrZ/Z4
            cyIkxfC6/rOqAirSdIp09EGiw7GM8guHyggE4IiZrDslT8V3xIl985cbCxSxeW1R
            tgH4rdEXuVe9+31oJhmXOE9ux2jCop9tEJMgWg7HStrJ5plPbb+HmjoX3nBO04E5
            6m52PyzMNV+2N21IPppKwA==
            -----END CERTIFICATE-----
            """.data(using: .utf8)!
            environment.udContact = """
      <xxc(2)7mbKFLE201WzH4SGxAOpHjjehwztIV+KGifi5L/PYPcDkAZiB9kZo+Dl3Vc7dD2SdZCFMOJVgwqGzfYRDkjc8RGEllBqNxq2sRRX09iQVef0kJQUgJCHNCOcvm6Ki0JJwvjLceyFh36iwK8oLbhLgqEZY86UScdACTyBCzBIab3ob5mBthYc3mheV88yq5PGF2DQ+dEvueUm+QhOSfwzppAJA/rpW9Wq9xzYcQzaqc3ztAGYfm2BBAHS7HVmkCbvZ/K07Xrl4EBPGHJYq12tWAN/C3mcbbBYUOQXyEzbSl/mO7sL3ORr0B4FMuqCi8EdlD6RO52pVhY+Cg6roRH1t5Ng1JxPt8Mv1yyjbifPhZ5fLKwxBz8UiFORfk0/jnhwgm25LRHqtNRRUlYXLvhv0HhqyYTUt17WNtCLATSVbqLrFGdy2EGadn8mP+kQNHp93f27d/uHgBNNe7LpuYCJMdWpoG6bOqmHEftxt0/MIQA8fTtTm3jJzv+7/QjZJDvQIv0SNdp8HFogpuwde+GuS4BcY7v5xz+ArGWcRR63ct2z83MqQEn9ODr1/gAAAgA7szRpDDQIdFUQo9mkWg8xBA==xxc>
      """.data(using: .utf8)

            let messenger = Messenger.live(environment)

            DependencyInjection.Container.shared.register(messenger)

            if messenger.isLoaded() == false {
                if messenger.isCreated() == false {
                    try messenger.create()
                }

                try messenger.load()
            }

            try messenger.start()

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

            if messenger.isConnected() == false {
                try messenger.connect()
            }

            try messenger.e2e.get()?.registerListener(
                senderId: nil,
                messageType: 2,
                callback: .init(handle: {
                    guard let payload = try? Payload(with: $0.payload) else {
                        fatalError("Couldn't decode payload: \(String(data: $0.payload, encoding: .utf8) ?? "nil")")
                    }

                    try! self.database.saveMessage(.init(
                        networkId: $0.id,
                        senderId: $0.sender,
                        recipientId: messenger.e2e.get()!.getContact().getId(),
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
                })
            )

            try generateGroupManager(messenger: messenger)
            try generateTrafficManager(messenger: messenger)
            try generateTransferManager(messenger: messenger)

            networkMonitor.start()

            if messenger.isLoggedIn() == false {
                if try messenger.isRegistered() == false {
                    hudSubject.send(.none)
                    routeSubject.send(.onboarding)
                } else {
                    hudSubject.send(.none)
                    checkBiometrics { [weak self] bioResult in

                        switch bioResult {
                        case .success(let granted):
                            if granted {
                                try! messenger.logIn()
                                self?.routeSubject.send(.chats)
                            } else {
                                // WHAT SHOULD HAPPEN HERE?
                            }
                        case .failure(let error):
                            print(">>> Bio auth failed: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                hudSubject.send(.none)
                checkBiometrics { [weak self] bioResult in
                    switch bioResult {
                    case .success(let granted):
                        if granted {
                            self?.routeSubject.send(.chats)
                        } else {
                            // WHAT SHOULD HAPPEN HERE?
                        }
                    case .failure(let error):
                        print(">>> Bio auth failed: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
            hudSubject.send(.error(.init(content: xxError)))
        }
    }

    private func cleanUp() {
//        try? cMixManager.remove()
//        try? keychainHandler.clear()
//        dropboxService.unlink()
    }

    private func presentOnboardingFlow() {
        hudSubject.send(.none)
        routeSubject.send(.onboarding)
    }

    private func setupDatabase() throws {
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

        DependencyInjection.Container.shared.register(database)

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

        guard let database: Database = try? DependencyInjection.Container.shared.resolve(),
              let contact = try? database.fetchContacts(query).first else {
            return nil
        }

        return contact
    }

    func getGroupInfoWith(groupId: Data) -> GroupInfo? {
        let query = GroupInfo.Query(groupId: groupId)

        guard let database: Database = try? DependencyInjection.Container.shared.resolve(),
              let info = try? database.fetchGroupInfos(query).first else {
            return nil
        }

        return info
    }

    private func versionFailed(error: Error) {
        let title = Localized.Launch.Version.failed
        let content = error.localizedDescription
        let hudError = HUDError(content: content, title: title, dismissable: false)

        hudSubject.send(.error(hudError))
    }

    private func versionUpdateRequired(_ info: DappVersionInformation) {
        hudSubject.send(.none)

        let model = Update(
            content: info.minimumMessage,
            urlString: info.appUrl,
            positiveActionTitle: Localized.Launch.Version.Required.positive,
            negativeActionTitle: nil,
            actionStyle: .brandColored
        )

        routeSubject.send(.update(model))
    }

    private func versionUpdateRecommended(_ info: DappVersionInformation) {
        hudSubject.send(.none)

        let model = Update(
            content: Localized.Launch.Version.Recommended.title,
            urlString: info.appUrl,
            positiveActionTitle: Localized.Launch.Version.Recommended.positive,
            negativeActionTitle: Localized.Launch.Version.Recommended.negative,
            actionStyle: .simplestColoredRed
        )

        routeSubject.send(.update(model))
    }

    private func checkBiometrics(completion: @escaping (Result<Bool, Error>) -> Void) {
        if permissionHandler.isBiometricsAvailable && isBiometricsOn {
            permissionHandler.requestBiometrics {
                switch $0 {
                case .success(let granted):
                    completion(.success(granted))

                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(true))
        }
    }

    private func updateErrors(completion: @escaping () -> Void) {
        let errorsURLString = "https://git.xx.network/elixxir/client-error-database/-/raw/main/clientErrors.json"

        URLSession.shared.dataTask(with: URL(string: errorsURLString)!) { [weak self] data, _, error in
            guard let self = self else { return }

            guard error == nil else {
                print(">>> Issue when trying to download errors json: \(error!.localizedDescription)")
                self.updateErrors(completion: completion)
                return
            }

            guard let data = data, let json = String(data: data, encoding: .utf8) else {
                print(">>> Issue when trying to unwrap errors json")
                return
            }

            do {
                try UpdateCommonErrors.live(jsonFile: json)
                completion()
            } catch {
                print(">>> Issue when trying to update common errors: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func updateBannedList(completion: @escaping () -> Void) {
        fetchBannedList { result in
            switch result {
            case .failure(_):
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.updateBannedList(completion: completion)
                }
            case .success(let data):
                self.processBannedList(data, completion: completion)
            }
        }
    }

    private func processBannedList(_ data: Data, completion: @escaping () -> Void) {
        processBannedList(
            data: data,
            forEach: { result in
                switch result {
                case .success(let userId):
                    let query = Contact.Query(id: [userId])
                    if var contact = try! database.fetchContacts(query).first {
                        if contact.isBanned == false {
                            contact.isBanned = true
                            try! database.saveContact(contact)
                            self.enqueueBanWarning(contact: contact)
                        }
                    } else {
                        try! database.saveContact(.init(id: userId, isBanned: true))
                    }

                case .failure(_):
                    break
                }
            },
            completion: { result in
                switch result {
                case .failure(_):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.updateBannedList(completion: completion)
                    }

                case .success(_):
                    completion()
                }
            }
        )
    }

    private func enqueueBanWarning(contact: XXModels.Contact) {
        let name = (contact.nickname ?? contact.username) ?? "One of your contacts"
        toastController.enqueueToast(model: .init(
            title: "\(name) has been banned for offensive content.",
            leftImage: Asset.requestSentToaster.image
        ))
    }
}

extension LaunchViewModel {
    private func generateGroupManager(messenger: Messenger) throws {
        let manager = try NewGroupChat.live(
            e2eId: messenger.e2e()!.getId(),
            groupRequest: .init(handle: { [weak self] group in
                guard let self = self else { return }
                self.handleGroupRequest(from: group)
            }),
            groupChatProcessor: .init(handle: { print(String(data: $0.msg, encoding: .utf8)) })
        )

        DependencyInjection.Container.shared.register(manager)
    }

    private func generateTransferManager(messenger: Messenger) throws {
        let manager = try InitFileTransfer.live(
            e2eId: messenger.e2e()!.getId(),
            callback: .init(handle: {
                switch $0 {
                case .success(let receivedFile):
                    print(receivedFile.name)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        )

        DependencyInjection.Container.shared.register(manager)
    }

    private func generateTrafficManager(messenger: Messenger) throws {
        let manager = try NewDummyTrafficManager.live(
            cMixId: messenger.e2e()!.getId(),
            maxNumMessages: 1,
            avgSendDeltaMS: 1,
            randomRangeMS: 1
        )

        DependencyInjection.Container.shared.register(manager)
        try! manager.setStatus(dummyTrafficOn)
    }
}

extension LaunchViewModel {
    private func handleDirectRequest(from contact: XXClient.Contact) {
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
            if email == nil, phone == nil {
                try performLookup(on: contact) { [weak self] in
                    guard let self = self else { return }

                    switch $0 {
                    case .success(let lookedUpContact):
                        if try! self.verifyOwnership(contact, lookedUpContact) { // How could this ever throw?
                            model.authStatus = .verified
                            try! self.database.saveContact(model)
                        } else {
                            try! self.database.deleteContact(model)
                        }
                    case .failure(let error):
                        model.authStatus = .verificationFailed
                        print(">>> Error \(#file):\(#line): \(error.localizedDescription)")
                        try! self.database.saveContact(model)
                    }
                }
            } else {
                try performSearch(on: contact) { [weak self] in
                    guard let self = self else { return }

                    switch $0 {
                    case .success(let searchedContact):
                        if try! self.verifyOwnership(contact, searchedContact) { // How could this ever throw?
                            model.authStatus = .verified
                            try! self.database.saveContact(model)
                        } else {
                            try! self.database.deleteContact(model)
                        }
                    case .failure(let error):
                        model.authStatus = .verificationFailed
                        print(">>> Error \(#file):\(#line): \(error.localizedDescription)")
                        try! self.database.saveContact(model)
                    }
                }
            }
        } catch {
            print(">>> Error \(#file):\(#line): \(error.localizedDescription)")
        }
    }

    private func handleConfirm(from contact: XXClient.Contact) {
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

    private func handleReset(from user: XXClient.Contact) {
        if var contact = try? database.fetchContacts(.init(id: [user.getId()])).first {
            contact.authStatus = .friend
            _ = try? database.saveContact(contact)
        }
    }

    private func handleGroupRequest(from group: XXClient.Group) {
        if let _ = try? database.fetchGroups(.init(id: [group.getId()])).first {
            print(">>> Tried to handle a group request that is already handled")
            return
        }

        guard let members = try? group.getMembership(), let leader = members.first else {
            fatalError("Failed to get group membership/leader")
        }

        try! database.saveGroup(.init(
            id: group.getId(),
            name: String(data: group.getName(), encoding: .utf8)!,
            leaderId: leader.id,
            createdAt: Date.fromTimestamp(Int(group.getCreatedMS())),
            authStatus: .pending,
            serialized: group.serialize()
        ))

//        if let initialMessage = String(data: group.getInitMessage(), encoding: .utf8) {
//            try! database.saveMessage(.init(
//                senderId: leader.id,
//                recipientId: nil,
//                groupId: group.getId(),
//                date: Date.fromTimestamp(Int(group.getCreatedMS())),
//                status: .received,
//                isUnread: true,
//                text: initialMessage
//            ))
//        }

        let friends = try! database.fetchContacts(.init(id: Set(members.map(\.id))))
        let strangers = members.filter { !friends.map(\.id).contains($0.id) }

        members.forEach {
            if strangers.map(\.id).contains($0.id) {
                try! database.saveContact(.init(
                    id: $0.id,
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
                    createdAt: Date()
                ))
            }
        }

        members.forEach {
            let model = XXModels.GroupMember(groupId: group.getId(), contactId: $0.id)
            _ = try? database.saveGroupMember(model)
        }

//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            // Multilookup on strangers
//        }
    }

    private func performLookup(
        on contact: XXClient.Contact,
        completion: @escaping (Result<XXClient.Contact, Error>) -> Void
    ) throws {
        guard let messenger = try? DependencyInjection.Container.shared.resolve() as Messenger else {
            fatalError(">>> Tried to lookup, but there's no messenger instance on DI container")
        }

        print(">>> Performing Lookup")

        let _ = try LookupUD.live(
            e2eId: messenger.e2e.get()!.getId(),
            udContact: try messenger.ud.get()!.getContact(),
            lookupId: contact.getId(),
            callback: .init(handle: {
                switch $0 {
                case .success(let otherContact):
                    print(">>> Lookup succeeded")
                    completion(.success(otherContact))
                case .failure(let error):
                    print(">>> Lookup failed: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            })
        )
    }

    private func performSearch(
        on contact: XXClient.Contact,
        completion: @escaping (Result<XXClient.Contact, Error>) -> Void
    ) throws {
        guard let messenger = try? DependencyInjection.Container.shared.resolve() as Messenger else {
            fatalError(">>> Tried to search, but there's no messenger instance on DI container")
        }

        print(">>> Performing Search")

        let _ = try SearchUD.live(
            e2eId: messenger.e2e.get()!.getId(),
            udContact: try messenger.ud.get()!.getContact(),
            facts: contact.getFacts(),
            callback: .init(handle: {
                switch $0 {
                case .success(let otherContact):
                    print(">>> Search succeeded")
                    completion(.success(otherContact.first!))
                case .failure(let error):
                    print(">>> Search failed: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            })
        )
    }

    private func verifyOwnership(
        _ lhs: XXClient.Contact,
        _ rhs: XXClient.Contact
    ) throws -> Bool {
        guard let messenger = try? DependencyInjection.Container.shared.resolve() as Messenger else {
            fatalError(">>> Tried to verify ownership, but there's no messenger instance on DI container")
        }

        let e2e = messenger.e2e.get()!
        return try e2e.verifyOwnership(received: lhs, verified: rhs, e2eId: e2e.getId())
    }
}
