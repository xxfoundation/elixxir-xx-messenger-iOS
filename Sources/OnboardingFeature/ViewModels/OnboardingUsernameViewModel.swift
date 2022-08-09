import HUD
import Shared
import Models
import Combine
import Defaults
import XXModels
import InputField
import XXClient
import CombineSchedulers
import DependencyInjection

import struct XXClient.FileTransfer

struct OnboardingUsernameViewState: Equatable {
    var input: String = ""
    var status: InputField.ValidationStatus = .unknown(nil)
}

final class OnboardingUsernameViewModel {
    @Dependency var database: Database
    @Dependency var cMixManager: CMixManager
    @Dependency var getIdFromContact: GetIdFromContact
    @Dependency var getFactsFromContact: GetFactsFromContact

    @KeyObject(.username, defaultValue: "") var username: String

    var backgroundScheduler: AnySchedulerOf<DispatchQueue>
    = DispatchQueue.global().eraseToAnyScheduler()

    var greenPublisher: AnyPublisher<Void, Never> { greenRelay.eraseToAnyPublisher() }
    private let greenRelay = PassthroughSubject<Void, Never>()

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var state: AnyPublisher<OnboardingUsernameViewState, Never> { stateRelay.eraseToAnyPublisher() }
    private let stateRelay = CurrentValueSubject<OnboardingUsernameViewState, Never>(.init())

    func didInput(_ string: String) {
        stateRelay.value.input = string.trimmingCharacters(in: .whitespacesAndNewlines)

        switch Validator.username.validate(stateRelay.value.input) {
        case .success(let text):
            stateRelay.value.status = .valid(text)
        case .failure(let error):
            stateRelay.value.status = .invalid(error)
        }
    }

    func didTapRegister() {
        hudRelay.send(.on)

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                let cMix = try self.initCMix()
                try cMix.startNetworkFollower(timeoutMS: 10_000)
                guard cMix.waitForNetwork(timeoutMS: 10_000) else {
                    fatalError("^^^ cMix.waitForNetwork returned FALSE")
                }
                let e2e = try self.initE2E(cMix)
                let ud = try self.initUD(alternative: true, e2e: e2e, cMix: cMix)
                _ = try self.initGroupManager(e2e)
                _ = try self.initTransferManager(e2e)
                _ = try self.initDummyTrafficManager(e2e)

                self.hudRelay.send(.none)
                self.greenRelay.send()
            } catch {
                self.hudRelay.send(.none)
                self.stateRelay.value.status = .invalid(error.localizedDescription)
            }
        }
    }

    private func initCMix() throws -> CMix {
        if let cMix = try? DependencyInjection.Container.shared.resolve() as CMix {
            return cMix
        }

        let cMix = try cMixManager.create()
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
            username: self.stateRelay.value.input,
            registrationValidationSignature: cMix.getReceptionRegistrationValidationSignature(),
            cert: cert,
            contactFile: contactFile,
            address: address
        ))

        username = self.stateRelay.value.input
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
}
