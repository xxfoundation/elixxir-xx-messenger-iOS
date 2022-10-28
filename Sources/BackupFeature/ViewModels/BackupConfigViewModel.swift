import HUD
import UIKit
import Models
import Shared
import Combine
import XXClient
import Defaults
import Foundation

import DependencyInjection

import CloudFiles

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
  var lastBackup: () -> AnyPublisher<Fetch.Metadata?, Never>
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
        context.service.didForceBackup()
        context.hud.update(with: .on)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          context.hud.update(with: .none)
        }
      },
      didChooseWifiOnly: context.service.didSetWiFiOnly(enabled:),
      didChooseAutomatic: context.service.didSetAutomaticBackup(enabled:),
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
      didTapService: { service, controller in
        if service == .sftp {
          context.coordinator.toSFTP(from: controller) { host, username, password in
            context.service.setupSFTP(host: host, username: username, password: password)
          }
          return
        }

        context.service.authorize(service: service, presenting: controller)
      },
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
          .combineLatest(context.service.backupsPublisher)
          .map { settings, backups in
            guard let enabled = settings.enabledService else { return nil }
            return backups[enabled]
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
        context.service.connectedServicesPublisher
          .removeDuplicates()
          .eraseToAnyPublisher()
      }
    )
  }
}
