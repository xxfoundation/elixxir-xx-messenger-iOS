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
import DropboxFeature
import VersionChecking
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
    case search
    case update(Update)
    case onboarding(String)
}

final class LaunchViewModel {
    @Dependency private var network: XXNetworking
    @Dependency private var versionChecker: VersionChecker
    @Dependency private var dropboxService: DropboxInterface
    @Dependency private var keychainHandler: KeychainHandling
    @Dependency private var permissionHandler: PermissionHandling

    @KeyObject(.username, defaultValue: nil) var username: String?
    @KeyObject(.invitation, defaultValue: nil) var invitation: String?
    @KeyObject(.biometrics, defaultValue: false) var isBiometricsOn: Bool

    var hudPublisher: AnyPublisher<HUDStatus, Never> {
        hudSubject.eraseToAnyPublisher()
    }

    var routePublisher: AnyPublisher<LaunchRoute, Never> {
        routeSubject.eraseToAnyPublisher()
    }

    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = {
        DispatchQueue.global().eraseToAnyScheduler()
    }()

    var getSession: (String) throws -> SessionType = Session.init

    private var cancellables = Set<AnyCancellable>()
    private let routeSubject = PassthroughSubject<LaunchRoute, Never>()
    private let hudSubject = CurrentValueSubject<HUDStatus, Never>(.none)

    func viewDidAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.hudSubject.send(.on)
            self?.checkVersion()
        }
    }

    private func checkVersion() {
        versionChecker().sink { [unowned self] in
            switch $0 {
            case .upToDate:
                versionApproved()
            case .failure(let error):
                versionFailed(error: error)
            case .updateRequired(let info):
                versionUpdateRequired(info)
            case .updateRecommended(let info):
                versionUpdateRecommended(info)
            }
        }.store(in: &cancellables)
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
                        let session = try self.getSession(ndf)
                        DependencyInjection.Container.shared.register(session as SessionType)
                        self.hudSubject.send(.none)
                        self.checkBiometrics()
                    } catch {
                        self.hudSubject.send(.error(HUDError(with: error)))
                    }
                }
            case .failure(let error):
                self.hudSubject.send(.error(HUDError(with: error)))
            }
        }
    }

    func getContactWith(userId: Data) -> Contact? {
        guard let session = try? DependencyInjection.Container.shared.resolve() as SessionType,
              let contact = try? session.dbManager.fetchContacts(.init(id: [userId])).first else {
            return nil
        }

        return contact
    }

    func getGroupInfoWith(groupId: Data) -> GroupInfo? {
        guard let session: SessionType = try? DependencyInjection.Container.shared.resolve(),
              let info = try? session.dbManager.fetchGroupInfos(.init(groupId: groupId)).first else {
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

    private func checkBiometrics() {
        if permissionHandler.isBiometricsAvailable && isBiometricsOn {
            permissionHandler.requestBiometrics { [weak self] in
                guard let self = self else { return }

                switch $0 {
                case .success(let granted):
                    guard granted else { return }

                    if self.invitation != nil {
                        self.routeSubject.send(.search)
                    } else {
                        self.routeSubject.send(.chats)
                    }

                case .failure(let error):
                    self.hudSubject.send(.error(HUDError(with: error)))
                }
            }
        } else {
            if self.invitation != nil {
                self.routeSubject.send(.search)
            } else {
                self.routeSubject.send(.chats)
            }
        }
    }
}
