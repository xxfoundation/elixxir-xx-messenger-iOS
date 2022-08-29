import HUD
import Shared
import Models
import Combine
import Defaults
import XXModels
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
    @Dependency var processBannedList: ProcessBannedList
    @Dependency var permissionHandler: PermissionHandling

    @KeyObject(.username, defaultValue: nil) var username: String?
    @KeyObject(.biometrics, defaultValue: false) var isBiometricsOn: Bool

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
                    self.updateBannedList { self.continueWithInitialization() }
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

            try SetLogLevel.live(.trace)

            guard let certPath = Bundle.module.path(forResource: "cmix.rip", ofType: "crt"),
                  let contactFilePath = Bundle.module.path(forResource: "udContact", ofType: "bin") else {
                fatalError("Couldn't retrieve alternative UD credentials")
            }

            let address = "46.101.98.49:18001"
            let cert = try Data(contentsOf: URL(fileURLWithPath: certPath))
            let contactFile = try Data(contentsOf: URL(fileURLWithPath: contactFilePath))

            var environment: MessengerEnvironment = .live()
            environment.udCert = cert
            environment.udAddress = address
            environment.udContact = contactFile
            environment.ndfEnvironment = .mainnet

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
                    print(">>> \(String(data: $0.payload, encoding: .utf8))")
                })
            )

            try generateGroupManager(messenger: messenger)
            try generateTrafficManager(messenger: messenger)
            try generateTransferManager(messenger: messenger)

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
            print(">>> Initialization couldn't be completed: \(error.localizedDescription)")
        }
    }

    private func cleanUp() {
//        try? cMixManager.remove()
//        try? keychainHandler.clear()
//
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
            groupChatProcessor: .init(handle: { print($0) }) // What is this?
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
        let email = facts?.first(where: { $0.type == FactType.email.rawValue })?.fact
        let phone = facts?.first(where: { $0.type == FactType.phone.rawValue })?.fact
        let username = facts?.first(where: { $0.type == FactType.username.rawValue })?.fact

        var model = try! database.saveContact(.init(
            id: id,
            marshaled: contact.data,
            username: username,
            email: email,
            phone: phone,
            nickname: nil,
            photo: nil,
            authStatus: .verificationInProgress,
            isRecent: false,
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

        existentContact.authStatus = .friend
        try! database.saveContact(existentContact)
    }

    private func handleReset(from contact: XXClient.Contact) {
        // TODO
    }

    private func handleGroupRequest(from group: XXClient.Group) {
        if let _ = try? database.fetchGroups(.init(id: [group.getId()])).first {
            print(">>> Tried to handle a group request that is already handled")
            return
        }

        let leaderId = try! group.getMembership() // This is all users on the group, the 1st is the leader/creator.

        try! database.saveGroup(.init(
            id: group.getId(),
            name: String(data: group.getName(), encoding: .utf8)!,
            leaderId: leaderId,
            createdAt: Date.fromTimestamp(Int(group.getCreatedMS())),
            authStatus: .pending,
            serialized: group.serialize()
        ))

        if let initialMessage = String(data: group.getInitMessage(), encoding: .utf8) {
            try! database.saveMessage(.init(
                senderId: leaderId,
                recipientId: nil,
                groupId: group.getId(),
                date: Date.fromTimestamp(Int(group.getCreatedMS())),
                status: .received,
                isUnread: true,
                text: initialMessage
            ))
        }

        // TODO:
        // All other members should be added to the database as GroupMembers
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
