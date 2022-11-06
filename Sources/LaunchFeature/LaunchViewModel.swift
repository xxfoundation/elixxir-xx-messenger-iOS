import Shared
import Combine
import Defaults
import XXModels
import XXLogger
import Keychain
import Foundation
import Permissions
import BackupFeature
import VersionChecking
import ReportingFeature
import CombineSchedulers
import DependencyInjection

import XXClient
import struct XXClient.FileTransfer
import class XXClient.Cancellable

import XXDatabase
import XXLegacyDatabaseMigrator
import XXMessengerClient
import NetworkMonitor

import CloudFiles
import CloudFilesSFTP
import CloudFilesDropbox

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
  case onboarding
}

final class LaunchViewModel {
  @Dependency var database: Database
  @Dependency var messenger: Messenger
  @Dependency var hudController: HUDController
  @Dependency var backupService: BackupService
  @Dependency var versionChecker: VersionChecker
  @Dependency var fetchBannedList: FetchBannedList
  @Dependency var reportingStatus: ReportingStatus
  @Dependency var toastController: ToastController
  @Dependency var keychainHandler: KeychainHandling
  @Dependency var networkMonitor: NetworkMonitoring
  @Dependency var processBannedList: ProcessBannedList
  @Dependency var permissionHandler: PermissionHandling

  @KeyObject(.username, defaultValue: nil) var username: String?
  @KeyObject(.biometrics, defaultValue: false) var isBiometricsOn: Bool
  @KeyObject(.acceptedTerms, defaultValue: false) var didAcceptTerms: Bool
  @KeyObject(.dummyTrafficOn, defaultValue: false) var dummyTrafficOn: Bool

  var authCallbacksCancellable: Cancellable?
  var backupCallbackCancellable: Cancellable?
  var networkCallbacksCancellable: Cancellable?
  var messageListenerCallbacksCancellable: Cancellable?

  var routePublisher: AnyPublisher<LaunchRoute, Never> {
    routeSubject.eraseToAnyPublisher()
  }

  private var scheduler: AnySchedulerOf<DispatchQueue> = {
    DispatchQueue.global().eraseToAnyScheduler()
  }()

  private let dropboxManager = CloudFilesManager.dropbox(
    appKey: "ppx0de5f16p9aq2",
    path: "/backup/backup.xxm"
  )

  private let sftpManager = CloudFilesManager.sftp(
    host: "",
    username: "",
    password: "",
    fileName: ""
  )

  var cancellables = Set<AnyCancellable>()
  let routeSubject = PassthroughSubject<LaunchRoute, Never>()

  func viewDidAppear() {
    scheduler.schedule(after: .init(.now() + 1)) { [weak self] in
      guard let self else { return }
      self.hudController.show()
      self.versionChecker()
        .sink { [unowned self] in
          switch $0 {
          case .upToDate:
            self.updateBannedList {
              self.updateErrors {
                self.continueWithInitialization()
              }
            }
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

  func continueWithInitialization() {
    do {
      try self.setupDatabase()

      setupLogWriter()
      setupAuthCallback()
      setupBackupCallback()
      setupMessageCallback()

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

      try generateGroupManager()
      try generateTrafficManager()
      try generateTransferManager()
      listenToNetworkUpdates()

      if messenger.isLoggedIn() == false {
        if try messenger.isRegistered() {
          try messenger.logIn()
          hudController.dismiss()
          routeSubject.send(.chats)
        } else {
          try? sftpManager.unlink()
          try? dropboxManager.unlink()
          hudController.dismiss()
          routeSubject.send(.onboarding)
        }
      } else {
        hudController.dismiss()
        routeSubject.send(.chats)
      }
      if !messenger.isBackupRunning() {
        try? messenger.resumeBackup()
      }
      // TODO: Biometric auth

    } catch {
      let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
      hudController.show(.init(content: xxError))
    }
  }

  private func cleanUp() {
    // try? cMixManager.remove()
    // try? keychainHandler.clear()
  }

  private func presentOnboardingFlow() {
    hudController.dismiss()
    routeSubject.send(.onboarding)
  }

  private func checkBiometrics(completion: @escaping (Result<Bool, Error>) -> Void) {
    if permissionHandler.isBiometricsAvailable && isBiometricsOn {
      permissionHandler.requestBiometrics {
        switch $0 {
        case .success(let granted):
          completion(.success(granted))

        case .failure(let error):
          completion(.failure(error))
        }
      }
    } else {
      completion(.success(true))
    }
  }

  private func updateErrors(completion: @escaping () -> Void) {
    let errorsURLString = "https://git.xx.network/elixxir/client-error-database/-/raw/main/clientErrors.json"

    URLSession.shared.dataTask(with: URL(string: errorsURLString)!) { [weak self] data, _, error in
      guard let self else { return }

      guard error == nil else {
        print(">>> Issue when trying to download errors json: \(error!.localizedDescription)")
        self.updateErrors(completion: completion)
        return
      }

      guard let data = data, let json = String(data: data, encoding: .utf8) else {
        print(">>> Issue when trying to unwrap errors json")
        return
      }

      do {
        try UpdateCommonErrors.live(jsonFile: json)
        completion()
      } catch {
        print(">>> Issue when trying to update common errors: \(error.localizedDescription)")
      }
    }.resume()
  }
}

//    viewModel.routePublisher
//      .receive(on: DispatchQueue.main)
//      .sink { [unowned self] in
//        switch $0 {
//        case .chats:
//          guard didAcceptTerms == true else {
//            navigator.perform(PresentTermsAndConditions(popAllowed: false))
//            return
//          }
//
//          if let pushRoute = pendingPushRoute {
//            switch pushRoute {
//            case .requests:
//              navigator.perform(PresentRequests())
//
//            case .search(username: let username):
//              navigator.perform(PresentSearch(searching: username))
//
//            case .groupChat(id: let groupId):
//              if let info = viewModel.getGroupInfoWith(groupId: groupId) {
//                navigator.perform(PresentGroupChat(model: info))
//                return
//              }
//              navigator.perform(PresentChatList())
//
//            case .contactChat(id: let userId):
//              if let model = viewModel.getContactWith(userId: userId) {
//                navigator.perform(PresentChat(contact: model))
//                return
//              }
//              navigator.perform(PresentChatList())
//            }
//
//            return
//          }
//
//          navigator.perform(PresentChatList())
//
//        case .onboarding:
//          navigator.perform(PresentOnboardingStart())
//
//        case .update(let model):
//          offerUpdate(model: model)
//        }
//      }.store(in: &cancellables)
