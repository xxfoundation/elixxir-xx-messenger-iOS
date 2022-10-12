import HUD
import UIKit
import Models
import Shared
import Combine
import XXClient
import Defaults
import Foundation

import DependencyInjection

enum BackupActionState {
  case backupFinished
  case backupAllowed(Bool)
  case backupInProgress(Float, Float)
}

struct BackupConfigViewModel {
  var didTapBackupNow: () -> Void
  var didChooseWifiOnly: (Bool) -> Void
  var didChooseAutomatic: (Bool) -> Void
  var didToggleService: (UIViewController, CloudService, Bool) -> Void
  var didTapService: (CloudService, UIViewController) -> Void

  var wifiOnly: () -> AnyPublisher<Bool, Never>
  var automatic: () -> AnyPublisher<Bool, Never>
  var lastBackup: () -> AnyPublisher<BackupModel?, Never>
  var actionState: () -> AnyPublisher<BackupActionState, Never>
  var enabledService: () -> AnyPublisher<CloudService?, Never>
  var connectedServices: () -> AnyPublisher<Set<CloudService>, Never>
}

extension BackupConfigViewModel {
  static func live() -> Self {
    class Context {
      @Dependency var hud: HUD
      @Dependency var service: BackupService
      @Dependency var coordinator: BackupCoordinating
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
      didToggleService: { controller, service, enabling in
        guard enabling == true else {
          context.service.toggle(service: service, enabling: false)
          context.service.stopBackups()
          return
        }

        context.coordinator.toPassphrase(from: controller, cancelClosure: {
          context.service.toggle(service: service, enabling: false)
        }, passphraseClosure: { passphrase in
          context.hud.update(with: .onTitle("Initializing and securing your backup file will take few seconds, please keep the app open."))
          context.service.toggle(service: service, enabling: enabling)
          context.service.initializeBackup(passphrase: passphrase)
          context.hud.update(with: .none)
        })
      },
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
          .print(">>> lastBackup updated!")
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
