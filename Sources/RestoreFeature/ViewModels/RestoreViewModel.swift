import UIKit
import Models
import Shared
import Combine
import Defaults
import Foundation
import BackupFeature
import DependencyInjection

import SFTPFeature
import iCloudFeature
import DropboxFeature
import GoogleDriveFeature

import XXModels
import XXDatabase

import XXClient
import XXMessengerClient

enum RestorationStep {
  case idle(CloudService, BackupModel?)
  case downloading(Float, Float)
  case failDownload(Error)
  case wrongPass
  case parsingData
  case done
}

extension RestorationStep: Equatable {
  static func ==(lhs: RestorationStep, rhs: RestorationStep) -> Bool {
    switch (lhs, rhs) {
    case (.done, .done), (.wrongPass, .wrongPass):
      return true
    case let (.failDownload(a), .failDownload(b)):
      return a.localizedDescription == b.localizedDescription
    case let (.downloading(a, b), .downloading(c, d)):
      return a == c && b == d
    case (.idle, _), (.downloading, _), (.parsingData, _),
      (.done, _), (.failDownload, _), (.wrongPass, _):
      return false
    }
  }
}

final class RestoreViewModel {
  @Dependency var database: Database
  @Dependency var messenger: Messenger
  @Dependency var sftpService: SFTPService
  @Dependency var iCloudService: iCloudInterface
  @Dependency var dropboxService: DropboxInterface
  @Dependency var googleService: GoogleDriveInterface

  @KeyObject(.username, defaultValue: nil) var username: String?
  @KeyObject(.phone, defaultValue: nil) var phone: String?
  @KeyObject(.email, defaultValue: nil) var email: String?

  var step: AnyPublisher<RestorationStep, Never> {
    stepRelay.eraseToAnyPublisher()
  }

  // TO REFACTOR:
  //
  private var pendingData: Data?

  private var passphrase: String!
  private let settings: RestoreSettings
  private let stepRelay: CurrentValueSubject<RestorationStep, Never>

  init(settings: RestoreSettings) {
    self.settings = settings
    self.stepRelay = .init(.idle(settings.cloudService, settings.backup))
  }

  func retryWith(passphrase: String) {
    self.passphrase = passphrase
    continueRestoring(data: pendingData!)
  }

  func didTapRestore(passphrase: String) {
    self.passphrase = passphrase

    guard let backup = settings.backup else { fatalError() }

    stepRelay.send(.downloading(0.0, backup.size))

    switch settings.cloudService {
    case .drive:
      downloadBackupForDrive(backup)
    case .dropbox:
      downloadBackupForDropbox(backup)
    case .icloud:
      downloadBackupForiCloud(backup)
    case .sftp:
      downloadBackupForSFTP(backup)
    }
  }

  private func downloadBackupForSFTP(_ backup: BackupModel) {
    sftpService.downloadBackup(path: backup.id) { [weak self] in
      guard let self = self else { return }
      self.stepRelay.send(.downloading(backup.size, backup.size))

      switch $0 {
      case .success(let data):
        self.continueRestoring(data: data)
      case .failure(let error):
        self.stepRelay.send(.failDownload(error))
      }
    }
  }

  private func downloadBackupForDropbox(_ backup: BackupModel) {
    dropboxService.downloadBackup(backup.id) { [weak self] in
      guard let self = self else { return }
      self.stepRelay.send(.downloading(backup.size, backup.size))

      switch $0 {
      case .success(let data):
        self.continueRestoring(data: data)
      case .failure(let error):
        self.stepRelay.send(.failDownload(error))
      }
    }
  }

  private func downloadBackupForiCloud(_ backup: BackupModel) {
    iCloudService.downloadBackup(backup.id) { [weak self] in
      guard let self = self else { return }
      self.stepRelay.send(.downloading(backup.size, backup.size))

      switch $0 {
      case .success(let data):
        self.continueRestoring(data: data)
      case .failure(let error):
        self.stepRelay.send(.failDownload(error))
      }
    }
  }

  private func downloadBackupForDrive(_ backup: BackupModel) {
    googleService.downloadBackup(backup.id) { [weak self] in
      if let stepRelay = self?.stepRelay {
        stepRelay.send(.downloading($0, backup.size))
      }
    } _: { [weak self] in
      guard let self = self else { return }

      switch $0 {
      case .success(let data):
        self.continueRestoring(data: data)
      case .failure(let error):
        self.stepRelay.send(.failDownload(error))
      }
    }
  }

  private func continueRestoring(data: Data) {
    stepRelay.send(.parsingData)

    DispatchQueue.global().async { [weak self] in
      guard let self = self else { return }

      do {
        print(">>> Calling messenger destroy")
        try self.messenger.destroy()

        print(">>> Calling restore backup")
        let result = try self.messenger.restoreBackup(
          backupData: data,
          backupPassphrase: self.passphrase
        )

        self.username = result.restoredParams.username
        let facts = try self.messenger.ud.tryGet().getFacts()
        self.email = facts.get(.email)?.value
        self.phone = facts.get(.phone)?.value

        print(">>> Calling wait for network")
        try self.messenger.waitForNetwork()

        print(">>> Calling waitForNodes")
        try self.messenger.waitForNodes(
          targetRatio: 0.5,
          sleepInterval: 3,
          retries: 15,
          onProgress: { print(">>> \($0)") }
        )

        print(">>> Calling multilookup")
        let multilookup = try self.messenger.lookupContacts(ids: result.restoredContacts)

        multilookup.contacts.forEach {
          print(">>> Found \(try! $0.getFact(.username)?.value)")

          try! self.database.saveContact(.init(
            id: try $0.getId(),
            marshaled: $0.data,
            username: try? $0.getFact(.username)?.value,
            email: nil,
            phone: nil,
            nickname: try? $0.getFact(.username)?.value,
            photo: nil,
            authStatus: .friend,
            isRecent: false,
            isBlocked: false,
            isBanned: false,
            createdAt: Date()
          ))
        }

        multilookup.errors.forEach {
          print(">>> Error: \($0.localizedDescription)")
        }

        self.stepRelay.send(.done)
      } catch {
        print(">>> Error on restoration: \(error.localizedDescription)")
        self.pendingData = data
        self.stepRelay.send(.wrongPass)
      }
    }
  }
}
