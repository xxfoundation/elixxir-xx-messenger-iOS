import UIKit
import Shared
import AppCore
import Combine
import XXClient
import Defaults
import CloudFiles
import AppNavigation
import ComposableArchitecture

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
      @Dependency(\.navigator) var navigator: Navigator
      @Dependency(\.backupService) var service: BackupService
      @Dependency(\.app.hudManager) var hudManager: HUDManager
    }

    let context = Context()

    return .init(
      didTapBackupNow: {
        context.service.didForceBackup()
        context.hudManager.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          context.hudManager.hide()
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
        context.navigator.perform(PresentPassphrase(onCancel: {
          context.service.toggle(service: service, enabling: false)
        }, onPassphrase: { passphrase in
          context.hudManager.show(.init(
            content: "Initializing and securing your backup file will take few seconds, please keep the app open."
          ))
          context.service.toggle(service: service, enabling: enabling)
          context.service.initializeBackup(passphrase: passphrase)
          context.hudManager.hide()
        }))
      },
      didTapService: { service, controller in
        if service == .sftp {
          context.navigator.perform(PresentSFTP(completion: { host, username, password in
            context.service.setupSFTP(host: host, username: username, password: password)
          }, on: controller.navigationController!))
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
