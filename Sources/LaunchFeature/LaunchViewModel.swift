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

import XXDatabase
import XXLegacyDatabaseMigrator

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
    @Dependency var cMixManager: CMixManager
    @Dependency var versionChecker: VersionChecker
    @Dependency var dropboxService: DropboxInterface
    @Dependency var fetchBannedList: FetchBannedList
    @Dependency var reportingStatus: ReportingStatus
    @Dependency var toastController: ToastController
    @Dependency var keychainHandler: KeychainHandling
    @Dependency var getIdFromContact: GetIdFromContact
    @Dependency var processBannedList: ProcessBannedList
    @Dependency var permissionHandler: PermissionHandling
    @Dependency var getFactsFromContact: GetFactsFromContact

    @KeyObject(.username, defaultValue: nil) var username: String?
    @KeyObject(.biometrics, defaultValue: false) var isBiometricsOn: Bool

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

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
                    self.versionApproved()
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

    func versionApproved() {
        //self.updateBannedList {

        _ = try? SetLogLevel.live(.trace)

        try! setupDatabase()

        if cMixManager.hasStorage(), username != nil {
            checkBiometrics { [weak self] in
                guard let self = self else { return }

                switch $0 {
                case .success(false):
                    break
                case .success(true):
                    do {
                        //UpdateCommonErrors.live(jsonFile: ) DOWNLOAD THE JSON FROM THE REPO

                        let cMix = try self.initCMix()
                        try cMix.startNetworkFollower(timeoutMS: 10_000)
                        guard cMix.waitForNetwork(timeoutMS: 10_000) else {
                            fatalError("^^^ cMix.waitForNetwork returned FALSE")
                        }

                        let e2e = try self.initE2E(cMix)
                        _ = try self.initUD(alternative: true, e2e: e2e, cMix: cMix)
                        _ = try self.initGroupManager(e2e)
                        _ = try self.initTransferManager(e2e)
                        _ = try self.initDummyTrafficManager(e2e)


                        self.hudSubject.send(.none)
                        self.routeSubject.send(.chats)
                    } catch {
                        self.hudSubject.send(.error(.init(with: error)))
                    }
                case .failure(let error):
                    self.hudSubject.send(.error(.init(with: error)))
                }
            case .failure(let error):
                self.hudSubject.send(.error(HUDError(with: error)))
            }
        } else {
            cleanUp()
            presentOnboardingFlow()
        }
    }

    private func cleanUp() {
        try? cMixManager.remove()
        try? keychainHandler.clear()

        dropboxService.unlink()
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

    func getContactWith(userId: Data) -> Contact? {
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

    private func initCMix() throws -> CMix {
        if let cMix = try? DependencyInjection.Container.shared.resolve() as CMix {
            return cMix
        }

        let cMix = try cMixManager.load()
        DependencyInjection.Container.shared.register(cMix)
        return cMix
    }

    private func initE2E(_ cMix: CMix) throws -> E2E {
        if let e2e = try? DependencyInjection.Container.shared.resolve() as E2E {
            return e2e
        }

        let e2e = try Login.live(
            cMixId: cMix.getId(),
            authCallbacks: .init(
                handle: {
                    switch $0 {
                    case .reset(contact: let contact, receptionId: _, ephemeralId: _, roundId: _):
                        self.handleReset(from: contact)
                    case .confirm(contact: let contact, receptionId: _, ephemeralId: _, roundId: _):
                        self.handleConfirm(from: contact)
                    case .request(contact: let contact, receptionId: _, ephemeralId: _, roundId: _):
                        self.handleRequest(from: contact)
                    }
                }
            ),
            identity: cMix.makeLegacyReceptionIdentity()
        )

        try e2e.registerListener(
            senderId: nil,
            messageType: 2,
            callback: .init(handle: { message in
                print(message.timestamp)
            })
        )

        DependencyInjection.Container.shared.register(e2e)
        return e2e
    }

    private func initUD(alternative: Bool, e2e: E2E, cMix: CMix) throws -> UserDiscovery {
        if let userDiscovery = try? DependencyInjection.Container.shared.resolve() as UserDiscovery {
            return userDiscovery
        }

        guard let certPath = Bundle.module.path(forResource: "cmix.rip", ofType: "crt"),
              let contactFilePath = Bundle.module.path(forResource: "udContact", ofType: "bin") else {
            fatalError("Couldn't retrieve alternative UD credentials")
        }

        let address = alternative ? "46.101.98.49:18001" : e2e.getUdAddressFromNdf()
        let cert = alternative ? try Data(contentsOf: URL(fileURLWithPath: certPath)) : e2e.getUdCertFromNdf()
        let contactFile = alternative ? try Data(contentsOf: URL(fileURLWithPath: contactFilePath)) : try e2e.getUdContactFromNdf()

        let userDiscovery = try NewOrLoadUd.live(.init(
            e2eId: e2e.getId(),
            follower: .init(handle: { cMix.networkFollowerStatus().rawValue }),
            username: username!,
            registrationValidationSignature: cMix.getReceptionRegistrationValidationSignature(),
            cert: cert,
            contactFile: contactFile,
            address: address
        ))

        DependencyInjection.Container.shared.register(userDiscovery)
        return userDiscovery
    }

    private func initGroupManager(_ e2e: E2E) throws -> GroupChat {
        if let groupManager = try? DependencyInjection.Container.shared.resolve() as GroupChat {
            return groupManager
        }

        let groupManager = try NewGroupChat.live(
            e2eId: e2e.getId(),
            groupRequest: .init(handle: { print($0) }),
            groupChatProcessor: .init(handle: { print($0) })
        )

        DependencyInjection.Container.shared.register(groupManager)
        return groupManager
    }

    private func initTransferManager(_ e2e: E2E) throws -> XXClient.FileTransfer {
        if let transferManager = try? DependencyInjection.Container.shared.resolve() as FileTransfer {
            return transferManager
        }

        let transferManager = try InitFileTransfer.live(
            e2eId: e2e.getId(),
            callback: .init(handle: {
                switch $0 {
                case .success(let receivedFile):
                    print(receivedFile.name)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        )

        DependencyInjection.Container.shared.register(transferManager)
        return transferManager
    }

    private func initDummyTrafficManager(_ e2e: E2E) throws -> DummyTraffic {
        if let dummyTrafficManager = try? DependencyInjection.Container.shared.resolve() as DummyTraffic {
            return dummyTrafficManager
        }

        let dummyTrafficManager = try NewDummyTrafficManager.live(
            cMixId: e2e.getId(),
            maxNumMessages: 1,
            avgSendDeltaMS: 1,
            randomRangeMS: 1
        )

        DependencyInjection.Container.shared.register(dummyTrafficManager)
        return dummyTrafficManager
    }

    private func handleRequest(from contact: Data) {
        guard isRepeatedRequest(from: contact) == false else { return }

        do {
            let facts = try? getFactsFromContact(contact: contact)

            let model = try self.database.saveContact(.init(
                id: try getIdFromContact(contact),
                marshaled: contact,
                username: facts?.first(where: { $0.type == FactType.username.rawValue })?.fact,
                email: facts?.first(where: { $0.type == FactType.email.rawValue })?.fact,
                phone: facts?.first(where: { $0.type == FactType.phone.rawValue })?.fact,
                nickname: nil,
                photo: nil,
                authStatus: .verificationInProgress,
                isRecent: true,
                createdAt: Date()
            ))

            if model.email == nil, model.phone == nil {
                performLookup(on: model)
            } else {
                //performSearch()
            }
        } catch {
            print("^^^ Request processing failed: \(error.localizedDescription)")
        }
    }

    private func isRepeatedRequest(from contact: Data) -> Bool {
        if let id = try? getIdFromContact(contact),
           let _ = try? self.database.fetchContacts(Contact.Query(id: [id])).first {
            return true
        }

        return false
    }

    private func performLookup(on contact: Contact) {
        guard let e2e = try? DependencyInjection.Container.shared.resolve() as E2E,
              let userDiscovery = try? DependencyInjection.Container.shared.resolve() as UserDiscovery else {
            print("^^^ couldn't resolve UD/E2E to process lookup")
            return
        }

        do {
            let _ = try LookupUD.live(
                e2eId: e2e.getId(),
                udContact: try userDiscovery.getContact(),
                lookupId: contact.id,
                callback: .init(handle: { [weak self] in
                    guard let self = self else { return }

                    switch $0 {
                    case .success(let id):
                        self.performOwnershipVerification(contact: contact, idLookedUp: id)
                    case .failure(let error):
                        print("^^^ Lookup failed: \(error.localizedDescription)")
                    }
                })
            )
        } catch {
            print("^^^ Error when trying to run lookup: \(error.localizedDescription)")
        }
    }

    private func performOwnershipVerification(contact: Contact, idLookedUp: Data) {
        guard let e2e = try? DependencyInjection.Container.shared.resolve() as E2E else {
            print("^^^ couldn't resolve E2E to process verification")
            return
        }

        do {
            let result = try e2e.verifyOwnership(
                receivedContact: contact.marshaled!,
                verifiedContact: idLookedUp,
                e2eId: e2e.getId()
            )

            if result == true {
                var contact = contact
                contact.authStatus = .verified
                try database.saveContact(contact)
            } else {
                try database.deleteContact(contact)
            }
        } catch {
            print("^^^ Exception thrown at verify ownership")
        }
    }

    private func handleConfirm(from contact: Data) {
        guard let id = try? getIdFromContact(contact) else {
            print("^^^ Couldn't get id from contact. Confirmation failed")
            return
        }

        if var model = try? database.fetchContacts(.init(id: [id])).first {
            model.authStatus = .friend
            _ = try? database.saveContact(model)
        }
    }

    private func handleReset(from contact: Data) {
        // TODO
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
                    if var contact = try! self.session.dbManager.fetchContacts(query).first {
                        if contact.isBanned == false {
                            contact.isBanned = true
                            try! self.session.dbManager.saveContact(contact)
                            self.enqueueBanWarning(contact: contact)
                        }
                    } else {
                        try! self.session.dbManager.saveContact(.init(id: userId, isBanned: true))
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

    private func enqueueBanWarning(contact: Contact) {
        let name = (contact.nickname ?? contact.username) ?? "One of your contacts"
        toastController.enqueueToast(model: .init(
            title: "\(name) has been banned for offensive content.",
            leftImage: Asset.requestSentToaster.image
        ))
    }
}
