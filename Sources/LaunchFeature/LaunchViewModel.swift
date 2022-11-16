import Shared
import Combine
import Defaults
import XXModels
import Keychain
import XXClient
import CloudFiles
import Foundation
import Permissions
import BackupFeature
import VersionChecking
import ReportingFeature
import CombineSchedulers
import CloudFilesDropbox
import XXMessengerClient

import class XXClient.Cancellable

final class LaunchViewModel {
  struct UpdateModel {
    let content: String
    let urlString: String
    let positiveActionTitle: String
    let negativeActionTitle: String?
    let actionStyle: CapsuleButtonStyle
  }

  struct ViewState {
    var shouldShowTerms = false
    var shouldPushChats = false
    var shouldOfferUpdate: UpdateModel?
    var shouldPushOnboarding = false
  }

  @Dependency var database: Database
  @Dependency var messenger: Messenger
  @Dependency var versionCheck: VersionCheck
  @Dependency var hudController: HUDController
  @Dependency var backupService: BackupService
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

  var statePublisher: AnyPublisher<ViewState, Never> {
    stateSubject.eraseToAnyPublisher()
  }

  private var scheduler: AnySchedulerOf<DispatchQueue> = {
    DispatchQueue.global().eraseToAnyScheduler()
  }()

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

  func viewDidAppear() {
    scheduler.schedule(after: .init(.now() + 1)) { [weak self] in
      guard let self else { return }
      self.startLaunch()
    }
  }

  private func startLaunch() {
    if !didAcceptTerms {
      stateSubject.value.shouldShowTerms = true
    }
    hudController.show()
    versionCheck.verify { [weak self] in
      guard let self else { return }
      switch $0 {
      case .upToDate:
        self.didVerifyVersion()
      case .failure(let error):
        self.hudController.show(.init(
          title: Localized.Launch.Version.failed,
          content: error.localizedDescription
        ))
      case .outdated(let info):
        self.hudController.dismiss()
        let isRequired = info.isRequired ?? false

        let content = isRequired ?
        info.minimumMessage :
        Localized.Launch.Version.Recommended.title

        let positiveActionTitle = isRequired ?
        Localized.Launch.Version.Required.positive :
        Localized.Launch.Version.Recommended.positive

        self.stateSubject.value.shouldOfferUpdate = .init(
          content: content,
          urlString: info.appUrl,
          positiveActionTitle: positiveActionTitle,
          negativeActionTitle: isRequired ? nil : Localized.Launch.Version.Recommended.negative,
          actionStyle: isRequired ? .brandColored : .simplestColoredRed
        )
      }
    }
  }

  func didRefuseUpdating() {
    hudController.show()
    didVerifyVersion()
  }

  private func didVerifyVersion() {
    updateBannedList { [weak self] in
      guard let self else { return }
      self.updateErrors {
        switch $0 {
        case .success:
          self.didFinishAsyncWork()
        case .failure(let error):
          self.hudController.show(.init(error: error))
        }
      }
    }
  }

  private func didFinishAsyncWork() {
    do {
      try setupDatabase()
      try setupMessenger()
    } catch {
      let xxError = CreateUserFriendlyErrorMessage.live(error.localizedDescription)
      hudController.show(.init(content: xxError))
    }
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
}
