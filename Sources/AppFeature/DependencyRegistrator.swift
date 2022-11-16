// MARK: SDK

import UIKit
import Network
import QuickLook
import MobileCoreServices

// MARK: Isolated features

import Bindings
import XXLogger
import Keychain
import Defaults
import Voxophone
import Permissions
import PushFeature
import CrashService
import CrashReporting
import VersionChecking
import ReportingFeature
import CountryListFeature
import DI

// MARK: UI Features

import ScanFeature
import ChatFeature
import MenuFeature
import TermsFeature
import BackupFeature
import DrawerFeature
import SearchFeature
import LaunchFeature
import RestoreFeature
import ContactFeature
import ProfileFeature
import ChatListFeature
import SettingsFeature
import RequestsFeature
import OnboardingFeature
import ContactListFeature

import Shared
import XXClient
import Navigation
import KeychainAccess
import XXMessengerClient

import ComposableArchitecture

struct DependencyRegistrator {
  static public func registerNavigators(_ navController: UINavigationController) {
//    container.register(CombinedNavigator(
//      PresentModalNavigator(),
//      DismissModalNavigator(),
//      PushNavigator(),
//      PopToRootNavigator(),
//      PopToNavigator(),
//      SetStackNavigator(),
//
//      OpenUpNavigator(),
//      OpenLeftNavigator(),
//
//      PresentOnboardingStartNavigator(
//        screen: OnboardingStartController.init,
//        navigationController: { navController }
//      ),
//      PresentChatListNavigator(
//        screen: ChatListController.init,
//        navigationController: { navController }
//      ),
//      PresentTermsAndConditionsNavigator(
//        screen: TermsConditionsController.init,
//        navigationController: { navController }
//      ),
//      PresentSearchNavigator(
//        screen: SearchContainerController.init(_:),
//        navigationController: { navController }
//      ),
//      PresentRequestsNavigator(
//        screen: RequestsContainerController.init,
//        navigationController: { navController }
//      ),
//      PresentChatNavigator(
//        screen: SingleChatController.init(_:),
//        navigationController: { navController }
//      ),
//      PresentGroupChatNavigator(
//        screen: GroupChatController.init(_:),
//        navigationController: { navController }
//      ),
//      PresentOnboardingWelcomeNavigator(
//        screen: OnboardingWelcomeController.init,
//        navigationController: { navController }
//      ),
//      PresentOnboardingUsernameNavigator(
//        screen: OnboardingUsernameController.init,
//        navigationController: { navController }
//      ),
//      PresentRestoreListNavigator(
//        screen: RestoreListController.init,
//        navigationController: { navController }
//      ),
//      PresentOnboardingEmailNavigator(
//        screen: OnboardingEmailController.init,
//        navigationController: { navController }
//      ),
//      PresentOnboardingPhoneNavigator(
//        screen: OnboardingPhoneController.init,
//        navigationController: { navController }
//      ),
//      PresentOnboardingCodeNavigator(
//        screen: OnboardingCodeController.init(_:_:_:),
//        navigationController: { navController }
//      ),
//      PresentDrawerNavigator(
//        screen: DrawerController.init(_:),
//        navigationController: { navController }
//      ),
//      PresentContactListNavigator(
//        screen: ContactListController.init,
//        navigationController: { navController }
//      ),
//      PresentMenuNavigator(
//        screen: MenuController.init(_:),
//        navigationController: { navController }
//      ),
//      PresentScanNavigator(
//        screen: ScanContainerController.init,
//        navigationController: { navController }
//      ),
//      PresentNewGroupNavigator(
//        screen: CreateGroupController.init,
//        navigationController: { navController }
//      ),
//      PresentCountryListNavigator(
//        screen: CountryListController.init(_:),
//        navigationController: { navController }
//      ),
//      PresentProfileNavigator(
//        screen: ProfileController.init,
//        navigationController: { navController }
//      ),
//      PresentSettingsNavigator(
//        screen: SettingsController.init,
//        navigationController: { navController }
//      ),
//      PresentSettingsAdvancedNavigator(
//        screen: SettingsAdvancedController.init,
//        navigationController: { navController }
//      ),
//      PresentSettingsBackupNavigator(
//        screen: BackupController.init,
//        navigationController: { navController }
//      ),
//      PresentSettingsAccountDeleteNavigator(
//        screen: AccountDeleteController.init,
//        navigationController: { navController }
//      ),
//      PresentContactNavigator(
//        screen: ContactController.init(_:),
//        navigationController: { navController }
//      ),
//      PresentActivitySheetNavigator(
//        screen: { UIActivityViewController(
//          activityItems: $0,
//          applicationActivities: nil
//        )},
//        navigationController: { navController }
//      ),
//      PresentProfileEmailNavigator(
//        screen: ProfileEmailController.init,
//        navigationController: { navController }
//      ),
//      PresentProfilePhoneNavigator(
//        screen: ProfilePhoneController.init,
//        navigationController: { navController }
//      ),
//      PresentPermissionRequestNavigator(
//        screen: RequestPermissionController.init,
//        navigationController: { navController }
//      ),
//      PresentPhotoLibraryNavigator(
//        screen: UIImagePickerController.init,
//        navigationController: { navController }
//      ),
//      PresentProfileCodeNavigator(
//        screen: ProfileCodeController.init(_:_:_:),
//        navigationController: { navController }
//      )
//    ) as Navigator)
  }
}

public struct OtherDependencies {
  public var voxophone: Voxophone
  public var sendReport: SendReport
  public var pushHandler: PushHandler
  public var versionCheck: VersionCheck
  public var backupService: BackupService
  public var hudController: HUDController
  public var crashReporter: CrashReporter
  public var networkMonitor: NetworkMonitor
  public var keyObjectStore: KeyObjectStore
  public var fetchBannedList: FetchBannedList
  public var toastController: ToastController
  public var reportingStatus: ReportingStatus
  public var keychainHandler: KeychainHandler
  public var makeReportDrawer: MakeReportDrawer
  public var statusBarStylist: StatusBarStylist
  public var getIdFromContact: GetIdFromContact
  public var permissionHandler: PermissionHandler
  public var processBannedList: ProcessBannedList
  public var makeAppScreenshot: MakeAppScreenshot
  public var getFactsFromContact: GetFactsFromContact
}

extension OtherDependencies {
  public static func live() -> OtherDependencies {
    .init(
      voxophone: .init(),
      sendReport: .live,
      pushHandler: .init(),
      versionCheck: .live,
      backupService: .init(),
      hudController: .init(),
      crashReporter: .live,
      networkMonitor: .init(),
      keyObjectStore: .userDefaults,
      fetchBannedList: .live,
      toastController: .init(),
      reportingStatus: .live(),
      keychainHandler: .init(),
      makeReportDrawer: .live,
      statusBarStylist: .init(),
      getIdFromContact: .live,
      permissionHandler: .init(),
      processBannedList: .live,
      makeAppScreenshot: .live,
      getFactsFromContact: .live
    )
  }

  public static let unimplemented = OtherDependencies(
    voxophone: .init(),
    sendReport: .unimplemented,
    pushHandler: .init(),
    versionCheck: .unimplemented,
    backupService: .init(),
    hudController: .init(),
    crashReporter: .noop,
    networkMonitor: .init(),
    keyObjectStore: .mock(dictionary: [:]),
    fetchBannedList: .unimplemented,
    toastController: .init(),
    reportingStatus: .mock(),
    keychainHandler: .init(),
    makeReportDrawer: .unimplemented,
    statusBarStylist: .init(),
    getIdFromContact: .live,
    permissionHandler: .init(),
    processBannedList: .unimplemented,
    makeAppScreenshot: .unimplemented,
    getFactsFromContact: .live
  )
}

private enum OtherDependenciesKey: DependencyKey {
  static let liveValue: OtherDependencies = .live()
  static let testValue: OtherDependencies = .unimplemented
}

extension DependencyValues {
  public var others: OtherDependencies {
    get { self[OtherDependenciesKey.self] }
    set { self[OtherDependenciesKey.self] = newValue }
  }
}
