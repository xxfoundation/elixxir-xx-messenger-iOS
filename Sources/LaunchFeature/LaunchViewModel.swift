import Shared
import Combine
import Defaults
import XXModels
import Keychain
import XXClient
import CloudFiles
import CheckVersion
import AppResources
import BackupFeature
import ReportingFeature
import CloudFilesDropbox
import XXMessengerClient

import UpdateErrors
import FetchBannedList
import ProcessBannedList

import AppCore
import Foundation
import PermissionsFeature
import ComposableArchitecture

import XXDatabase
import XXLegacyDatabaseMigrator

import class XXClient.Cancellable

import PulseLogHandler

final class LaunchViewModel {
  enum Destination {
    case chats, onboarding
  }

  struct UpdateModel {
    let content: String
    let urlString: String
    let positiveActionTitle: String
    let negativeActionTitle: String?
    let actionStyle: CapsuleButtonStyle
  }

  struct ViewState {
    var shouldShowTerms = false
    var shouldOfferUpdate: UpdateModel?
    var shouldPushEndDestination: Destination?
  }

  @Dependency(\.app.log) var log
  @Dependency(\.app.bgQueue) var bgQueue
  @Dependency(\.permissions) var permissions
  @Dependency(\.app.messenger) var messenger
  @Dependency(\.app.dbManager) var dbManager
  @Dependency(\.updateErrors) var updateErrors
  @Dependency(\.hudManager) var hudManager
  @Dependency(\.checkVersion) var checkVersion
  @Dependency(\.dummyTraffic) var dummyTraffic
  @Dependency(\.app.toastManager) var toastManager
  @Dependency(\.fetchBannedList) var fetchBannedList
  @Dependency(\.reportingStatus) var reportingStatus
  @Dependency(\.app.networkMonitor) var networkMonitor
  @Dependency(\.processBannedList) var processBannedList

  @Dependency(\.app.authHandler) var authHandler
  @Dependency(\.app.groupRequest) var groupRequest
  @Dependency(\.app.backupHandler) var backupHandler
  @Dependency(\.app.messageListener) var messageListener
  @Dependency(\.app.receiveFileHandler) var receiveFileHandler
  @Dependency(\.app.groupMessageHandler) var groupMessageHandler

  var authHandlerCancellable: Cancellable?
  var groupRequestCancellable: Cancellable?
  var backupHandlerCancellable: Cancellable?
  var networkHandlerCancellable: Cancellable?
  var receiveFileHandlerCancellable: Cancellable?
  var groupMessageHandlerCancellable: Cancellable?
  var messageListenerHandlerCancellable: Cancellable?

  @KeyObject(.username, defaultValue: nil) var username: String?
  @KeyObject(.biometrics, defaultValue: false) var isBiometricsOn: Bool
  @KeyObject(.acceptedTerms, defaultValue: false) var didAcceptTerms: Bool
  @KeyObject(.dummyTrafficOn, defaultValue: false) var dummyTrafficOn: Bool

  var statePublisher: AnyPublisher<ViewState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  let dropboxManager = CloudFilesManager.dropbox(
    appKey: "ppx0de5f16p9aq2",
    path: "/backup/backup.xxm"
  )

  let sftpManager = CloudFilesManager.sftp(
    host: "",
    username: "",
    password: "",
    fileName: ""
  )

  let stateSubject = CurrentValueSubject <ViewState, Never>(.init())

  func startLaunch() {
    if !didAcceptTerms {
      stateSubject.value.shouldShowTerms = true
    }
    hudManager.show()
    checkVersion {
      switch $0 {
      case .success(let result):
        switch result {
        case .updated:
          self.didVerifyVersion()
        case .outdated(let appUrl):
          self.hudManager.hide()

          self.stateSubject.value.shouldOfferUpdate = .init(
            content: Localized.Launch.Version.Recommended.title,
            urlString: appUrl,
            positiveActionTitle: Localized.Launch.Version.Recommended.positive,
            negativeActionTitle: Localized.Launch.Version.Recommended.negative,
            actionStyle: .simplestColoredRed
          )
        case .wayTooOld(let appUrl, let minimumVersionMessage):
          self.hudManager.hide()

          self.stateSubject.value.shouldOfferUpdate = .init(
            content: minimumVersionMessage,
            urlString: appUrl,
            positiveActionTitle: Localized.Launch.Version.Required.positive,
            negativeActionTitle: nil,
            actionStyle: .brandColored
          )
        }
      case .failure(let error):
        self.hudManager.show(.init(
          title: Localized.Launch.Version.failed,
          content: error.localizedDescription
        ))
      }
    }
  }

  func didRefuseUpdating() {
    hudManager.show()
    didVerifyVersion()
  }

  private func didVerifyVersion() {
    updateBannedList {
      self.updateErrors {
        switch $0 {
        case .success:
          do {
            if !self.dbManager.hasDB() {
              try self.dbManager.makeDB()
            }
            try self.setupMessenger()
          } catch {
            let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
            self.hudManager.show(.init(content: xxError))
          }
        case .failure(let error):
          self.hudManager.show(.init(error: error))
        }
      }
    }
  }
}

extension LaunchViewModel {
  func setupMessenger() throws {
    _ = try messenger.setLogLevel(.trace)
    messenger.startLogging()

    authHandlerCancellable = authHandler { [weak self] in
      self?.log(.error($0 as NSError))
    }
    backupHandlerCancellable = backupHandler { [weak self] in
      self?.log(.error($0 as NSError))
    }
    receiveFileHandlerCancellable = receiveFileHandler { [weak self] in
      self?.log(.error($0 as NSError))
    }
    messageListenerHandlerCancellable = messageListener { [weak self] in
      self?.log(.error($0 as NSError))
    }

    if messenger.isLoaded() == false {
      if messenger.isCreated() == false {
        try messenger.create()
      }
      try messenger.load()
    }
    try messenger.start()
    if messenger.isConnected() == false {
      try messenger.connect()
      try messenger.listenForMessages()
    }

    let dummyTrafficManager = try NewDummyTrafficManager.live(
      cMixId: messenger.e2e()!.getId()
    )
    dummyTraffic.set(dummyTrafficManager)

    try dummyTrafficManager.setStatus(dummyTrafficOn)

    let endDestination: Destination

    if messenger.isLoggedIn() == false {
      if try messenger.isRegistered() {
        try messenger.logIn()
        endDestination = .chats
      } else {
        try? sftpManager.unlink()
        try? dropboxManager.unlink()
        endDestination = .onboarding
      }
    } else {
      endDestination = .chats
    }

    defer {
      hudManager.hide()
      if endDestination == .chats {
        if isBiometricsOn, permissions.biometrics.status() {
          permissions.biometrics.request { [weak self] granted in
            guard let self else { return }
            if granted {
              self.stateSubject.value.shouldPushEndDestination = .chats
            } else {
              // TODO: A fallback state for failing biometrics
            }
          }
        } else {
          stateSubject.value.shouldPushEndDestination = .chats
        }
      } else {
        stateSubject.value.shouldPushEndDestination = .onboarding
      }
    }

    if !messenger.isBackupRunning() {
      try? messenger.resumeBackup()
    }

    groupRequestCancellable = groupRequest { [weak self] in
      self?.log(.error($0 as NSError))
    }

    groupMessageHandlerCancellable = groupMessageHandler { [weak self] in
      self?.log(.error($0 as NSError))
    }

    try messenger.startGroupChat()

    try messenger.trackServices { [weak self] in
      self?.log(.error($0 as NSError))
    }

    try messenger.startFileTransfer()

    networkMonitor.start()
    networkHandlerCancellable = messenger.cMix.get()!.addHealthCallback(
      HealthCallback {
        self.networkMonitor.update($0)
      }
    )

    try failPendingProcessesFromLastSession()
  }
}

extension LaunchViewModel {
  func failPendingProcessesFromLastSession() throws {
    try dbManager.getDB().bulkUpdateMessages(
      .init(status: [.sending]),
      .init(status: .sendingFailed)
    )
  }

  func updateBannedList(completion: @escaping () -> Void) {
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

  func processBannedList(_ data: Data, completion: @escaping () -> Void) {
    processBannedList(
      data: data,
      forEach: { result in
        switch result {
        case .success(let userId):
          let query = Contact.Query(id: [userId])
          if var contact = try! dbManager.getDB().fetchContacts(query).first {
            if contact.isBanned == false {
              contact.isBanned = true
              try! dbManager.getDB().saveContact(contact)
              enqueueBanWarning(contact: contact)
            }
          } else {
            try! dbManager.getDB().saveContact(.init(id: userId, isBanned: true))
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

  func enqueueBanWarning(contact: XXModels.Contact) {
    let name = (contact.nickname ?? contact.username) ?? "One of your contacts"
    toastManager.enqueue(.init(
      title: "\(name) has been banned for offensive content.",
      leftImage: Asset.requestSentToaster.image
    ))
  }

  func getContactWith(userId: Data) -> XXModels.Contact? {
    try? dbManager.getDB().fetchContacts(.init(
      id: [userId],
      isBlocked: reportingStatus.isEnabled() ? false : nil,
      isBanned: reportingStatus.isEnabled() ? false : nil
    )).first
  }

  func getGroupInfoWith(groupId: Data) -> GroupInfo? {
    try? dbManager.getDB().fetchGroupInfos(.init(groupId: groupId)).first
  }
}
