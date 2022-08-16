import HUD
import Shared
import Models
import Combine
import Defaults
import XXModels
import Keychain
import Foundation
import Integration
import Permissions
import ToastFeature
import DropboxFeature
import VersionChecking
import ReportingFeature
import CombineSchedulers
import DependencyInjection

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
    case onboarding(String)
}

final class LaunchViewModel {
    @Dependency private var network: XXNetworking
    @Dependency private var versionChecker: VersionChecker
    @Dependency private var dropboxService: DropboxInterface
    @Dependency private var keychainHandler: KeychainHandling
    @Dependency private var permissionHandler: PermissionHandling
    @Dependency private var fetchBannedList: FetchBannedList
    @Dependency private var processBannedList: ProcessBannedList
    @Dependency private var toastController: ToastController
    @Dependency private var session: SessionType

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
        network.writeLogs()

        network.updateNDF { [weak self] in
            guard let self = self else { return }

            switch $0 {
            case .success(let ndf):
                self.network.updateErrors()

                guard self.network.hasClient else {
                    self.hudSubject.send(.none)
                    self.routeSubject.send(.onboarding(ndf))
                    self.dropboxService.unlink()
                    try? self.keychainHandler.clear()
                    return
                }

                guard self.username != nil else {
                    self.network.purgeFiles()
                    self.hudSubject.send(.none)
                    self.routeSubject.send(.onboarding(ndf))
                    self.dropboxService.unlink()
                    try? self.keychainHandler.clear()
                    return
                }

                self.backgroundScheduler.schedule { [weak self] in
                    guard let self = self else { return }

                    do {
                        let session = try Session(ndf: ndf)
                        DependencyInjection.Container.shared.register(session as SessionType)

                        self.updateBannedList {
                            DispatchQueue.main.async {
                                self.hudSubject.send(.none)
                                self.checkBiometrics()
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.hudSubject.send(.error(HUDError(with: error)))
                        }
                    }
                }

            case .failure(let error):
                self.hudSubject.send(.error(HUDError(with: error)))
            }
        }
    }

    func getContactWith(userId: Data) -> Contact? {
        let query = Contact.Query(id: [userId], isBlocked: false, isBanned: false)
        return try! session.dbManager.fetchContacts(query).first
    }

    func getGroupInfoWith(groupId: Data) -> GroupInfo? {
        let query = GroupInfo.Query(groupId: groupId)
        return try! session.dbManager.fetchGroupInfos(query).first
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

    private func checkBiometrics() {
        if permissionHandler.isBiometricsAvailable && isBiometricsOn {
            permissionHandler.requestBiometrics { [weak self] in
                guard let self = self else { return }

                switch $0 {
                case .success(let granted):
                    guard granted else { return }
                    self.routeSubject.send(.chats)

                case .failure(let error):
                    self.hudSubject.send(.error(HUDError(with: error)))
                }
            }
        } else {
            self.routeSubject.send(.chats)
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
