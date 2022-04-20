import HUD
import Shared
import Combine
import Defaults
import Foundation
import Integration
import Permissions
import VersionChecking
import CombineSchedulers
import DependencyInjection
import DropboxFeature

struct UpdatePopupModel {
    let body: String
    let updateTitle: String
    let updateStyle: CapsuleButtonStyle
    let notNowTitle: String?
    let appUrl: String
}

final class OnboardingLaunchViewModel {
    // MARK: Stored

    @KeyObject(.username, defaultValue: nil) var username: String?
    @KeyObject(.biometrics, defaultValue: false) var isBiometricsEnabled: Bool

    // MARK: Injected

    @Dependency private var network: XXNetworking
    @Dependency private var versioning: VersionChecker
    @Dependency private var permissions: PermissionHandling
    @Dependency private var dropboxService: DropboxInterface

    // MARK: Properties

    var getSession: (String) throws -> SessionType = Session.init
    var backgroundScheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.global().eraseToAnyScheduler()

    var chatsPublisher: AnyPublisher<Void, Never> { chatsRelay.eraseToAnyPublisher() }
    private let chatsRelay = PassthroughSubject<Void, Never>()

    var usernamePublisher: AnyPublisher<String, Never> { usernameRelay.eraseToAnyPublisher() }
    private let usernameRelay = PassthroughSubject<String, Never>()

    var hud: AnyPublisher<HUDStatus, Never> { hudRelay.eraseToAnyPublisher() }
    private let hudRelay = CurrentValueSubject<HUDStatus, Never>(.none)

    var updatePublisher: AnyPublisher<UpdatePopupModel, Never> { updateRelay.eraseToAnyPublisher() }
    private let updateRelay = PassthroughSubject<UpdatePopupModel, Never>()

    private var cancellables = Set<AnyCancellable>()

    func didFinishSplash() {
        hudRelay.send(.on(nil))

        versioning()
            .sink { [unowned self] in
                switch $0 {
                case .upToDate:
                    versionApproved()
                case .updateRecommended(let info):
                    hudRelay.send(.none)
                    updateRelay.send(.init(
                        body: "There is a new version available that enhance the current performance and usability.",
                        updateTitle: "Update",
                        updateStyle: .simplestColoredRed,
                        notNowTitle: "Not now",
                        appUrl: info.appUrl
                    ))
                case .updateRequired(let info):
                    hudRelay.send(.none)

                    updateRelay.send(.init(
                        body: info.minimumMessage,
                        updateTitle: "Okay",
                        updateStyle: .brandColored,
                        notNowTitle: nil,
                        appUrl: info.appUrl
                    ))
                case .failure(let error):
                    hudRelay.send(.error(.init(
                        content: error.localizedDescription,
                        title: "Failed checking app version",
                        dismissable: false
                    )))
                }
            }
            .store(in: &cancellables)
    }

    func versionApproved() {
        hudRelay.send(.on(nil))
        network.writeLogs()

        network.updateNDF { [weak self] in
            switch $0 {
            case .success(let ndf):
                self?.ndfApproved(ndf: ndf)
            case .failure(let error):
                print(error)
                self?.hudRelay.send(.error(.init(with: error)))
            }
        }
    }

    private func ndfApproved(ndf: String) {
        network.updateErrors()

        guard network.hasClient == true else {
            hudRelay.send(.none)
            usernameRelay.send(ndf)
            dropboxService.unlink()
            return
        }

        guard username != nil else {
            network.purgeFiles()
            hudRelay.send(.none)
            usernameRelay.send(ndf)
            dropboxService.unlink()
            return
        }

        backgroundScheduler.schedule { [weak self] in
            guard let self = self else { return }

            do {
                let session = try self.getSession(ndf)
                DependencyInjection.Container.shared.register(session as SessionType)
                self.hudRelay.send(.none)
                self.checkBiometrics()
            } catch {
                self.hudRelay.send(.error(.init(with: error)))
                print(error.localizedDescription)
            }
        }
    }

    private func checkBiometrics() {
        if permissions.isBiometricsAvailable && isBiometricsEnabled {
            permissions.requestBiometrics { result in
                switch result {
                case .success(let granted):
                    if granted {
                        self.chatsRelay.send()
                    } else {
                        // TODO
                    }

                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else {
            self.chatsRelay.send()
        }
    }
}
