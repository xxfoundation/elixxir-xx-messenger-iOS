import UIKit
import Models
import Shared
import Combine
import Foundation
import DependencyInjection
import HUD

enum BackupActionState {
    case backupFinished
    case backupAllowed(Bool)
    case backupInProgress(Float, Float)
}

struct BackupConfigViewModel {
    var didTapBackupNow: () -> Void
    var didChooseWifiOnly: (Bool) -> Void
    var didChooseAutomatic: (Bool) -> Void
    var didToggleService: (CloudService, Bool) -> Void
    var didTapService: (CloudService, UIViewController) -> Void

    var wifiOnly: () -> AnyPublisher<Bool, Never>
    var automatic: () -> AnyPublisher<Bool, Never>
    var lastBackup: () -> AnyPublisher<Backup?, Never>
    var actionState: () -> AnyPublisher<BackupActionState, Never>
    var enabledService: () -> AnyPublisher<CloudService?, Never>
    var connectedServices: () -> AnyPublisher<Set<CloudService>, Never>
}

extension BackupConfigViewModel {
    static func live() -> Self {
        class Context {
            @Dependency var hud: HUDType
            @Dependency var service: BackupService
        }

        let context = Context()

        return .init(
            didTapBackupNow: {
                context.service.performBackup()
                context.hud.update(with: .on)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    context.hud.update(with: .none)
                }
            },
            didChooseWifiOnly: context.service.setBackupOnlyOnWifi(_:),
            didChooseAutomatic: context.service.setBackupAutomatically(_:),
            didToggleService: context.service.toggle,
            didTapService: context.service.authorize,
            wifiOnly: {
                context.service.settingsPublisher
                    .map(\.wifiOnlyBackup)
                    .eraseToAnyPublisher()
            },
            automatic: {
                context.service.settingsPublisher
                    .map(\.automaticBackups)
                    .eraseToAnyPublisher()
            },
            lastBackup: {
                context.service.settingsPublisher
                    .map {
                        guard let enabledService = $0.enabledService else { return nil }
                        return $0.backups[enabledService]
                    }.eraseToAnyPublisher()
            },
            actionState: {
                context.service.settingsPublisher
                    .map(\.enabledService)
                    .map { BackupActionState.backupAllowed($0 != nil) }
                    .eraseToAnyPublisher()
            },
            enabledService: {
                context.service.settingsPublisher
                    .map(\.enabledService)
                    .eraseToAnyPublisher()
            },
            connectedServices: {
                context.service.settingsPublisher
                    .map(\.connectedServices)
                    .removeDuplicates()
                    .eraseToAnyPublisher()
            }
        )
    }
}
