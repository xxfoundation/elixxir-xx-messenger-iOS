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
import Countries
import Voxophone
import Permissions
import PushFeature
import CrashService
import CrashReporting
import NetworkMonitor
import VersionChecking
import ReportingFeature
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
import XXNavigation
import KeychainAccess
import XXMessengerClient

struct DependencyRegistrator {
  static private let container = DI.Container.shared

  static func registerDependencies() {
    #if DEBUG
    DependencyRegistrator.registerForMock()
    #else
    DependencyRegistrator.registerForLive()
    #endif
  }

  // MARK: MOCK

  static func registerForMock() {
    container.register(XXLogger.noop)
    container.register(VersionCheck.mock)
    container.register(CrashReporter.noop)
    container.register(ReportingStatus.mock())
    container.register(SendReport.mock())
    container.register(MockNetworkMonitor() as NetworkMonitoring)
    container.register(KeyObjectStore.userDefaults)
    container.register(MockPushHandler() as PushHandling)
    container.register(MockKeychainHandler() as KeychainHandling)
    container.register(MockPermissionHandler() as PermissionHandling)

    registerCommonDependencies()
  }

  // MARK: LIVE

  static func registerForLive() {
    let cMixManager = CMixManager.live(passwordStorage: .keychain)
    container.register(cMixManager)

    container.register(GetIdFromContact.live)
    container.register(GetFactsFromContact.live)

    container.register(KeyObjectStore.userDefaults)
    container.register(XXLogger.live())
    container.register(VersionCheck.live)
    container.register(CrashReporter.live)
    container.register(ReportingStatus.live())
    container.register(SendReport.live)

    container.register(NetworkMonitor() as NetworkMonitoring)
    container.register(PushHandler() as PushHandling)
    container.register(KeychainHandler() as KeychainHandling)
    container.register(PermissionHandler() as PermissionHandling)

    registerCommonDependencies()
  }

  // MARK: COMMON

  static public func registerNavigators(_ navController: UINavigationController) {
    container.register(CombinedNavigator(
      PresentModalNavigator(),
      DismissModalNavigator(),
      PushNavigator(),
      PopToRootNavigator(),
      PopToNavigator(),
      SetStackNavigator(),

      OpenUpNavigator(),
      OpenLeftNavigator(),

      PresentOnboardingStartNavigator(
        screen: OnboardingStartController.init,
        navigationController: { navController }
      ),
      PresentChatListNavigator(
        screen: ChatListController.init,
        navigationController: { navController }
      ),
      PresentTermsAndConditionsNavigator(
        screen: TermsConditionsController.init,
        navigationController: { navController }
      ),
      PresentSearchNavigator(
        screen: SearchContainerController.init(_:),
        navigationController: { navController }
      ),
      PresentRequestsNavigator(
        screen: RequestsContainerController.init,
        navigationController: { navController }
      ),
      PresentChatNavigator(
        screen: SingleChatController.init(_:),
        navigationController: { navController }
      ),
      PresentGroupChatNavigator(
        screen: GroupChatController.init(_:),
        navigationController: { navController }
      ),
      PresentOnboardingWelcomeNavigator(
        screen: OnboardingWelcomeController.init,
        navigationController: { navController }
      ),
      PresentOnboardingUsernameNavigator(
        screen: OnboardingUsernameController.init,
        navigationController: { navController }
      ),
      PresentRestoreListNavigator(
        screen: RestoreListController.init,
        navigationController: { navController }
      ),
      PresentOnboardingEmailNavigator(
        screen: OnboardingEmailController.init,
        navigationController: { navController }
      ),
      PresentOnboardingPhoneNavigator(
        screen: OnboardingPhoneController.init,
        navigationController: { navController }
      ),
      PresentOnboardingCodeNavigator(
        screen: OnboardingCodeController.init(_:_:_:),
        navigationController: { navController }
      ),
      PresentDrawerNavigator(
        screen: DrawerController.init(_:),
        navigationController: { navController }
      ),
      PresentContactListNavigator(
        screen: ContactListController.init,
        navigationController: { navController }
      ),
      PresentMenuNavigator(
        screen: MenuController.init(_:),
        navigationController: { navController }
      ),
      PresentScanNavigator(
        screen: ScanContainerController.init,
        navigationController: { navController }
      ),
      PresentNewGroupNavigator(
        screen: CreateGroupController.init,
        navigationController: { navController }
      ),
      PresentCountryListNavigator(
        screen: CountryListController.init(_:),
        navigationController: { navController }
      ),
      PresentProfileNavigator(
        screen: ProfileController.init,
        navigationController: { navController }
      ),
      PresentSettingsNavigator(
        screen: SettingsController.init,
        navigationController: { navController }
      ),
      PresentSettingsAdvancedNavigator(
        screen: SettingsAdvancedController.init,
        navigationController: { navController }
      ),
      PresentSettingsBackupNavigator(
        screen: BackupController.init,
        navigationController: { navController }
      ),
      PresentSettingsAccountDeleteNavigator(
        screen: AccountDeleteController.init,
        navigationController: { navController }
      ),
      PresentContactNavigator(
        screen: ContactController.init(_:),
        navigationController: { navController }
      ),
      PresentActivitySheetNavigator(
        screen: { UIActivityViewController(
          activityItems: $0,
          applicationActivities: nil
        )},
        navigationController: { navController }
      ),
      PresentProfileEmailNavigator(
        screen: ProfileEmailController.init,
        navigationController: { navController }
      ),
      PresentProfilePhoneNavigator(
        screen: ProfilePhoneController.init,
        navigationController: { navController }
      ),
      PresentPermissionRequestNavigator(
        screen: RequestPermissionController.init,
        navigationController: { navController }
      ),
      PresentPhotoLibraryNavigator(
        screen: UIImagePickerController.init,
        navigationController: { navController }
      ),
      PresentProfileCodeNavigator(
        screen: ProfileCodeController.init(_:_:_:),
        navigationController: { navController }
      )
    ) as Navigator)
  }

  static private func registerCommonDependencies() {
    var environment: MessengerEnvironment = .live()
    environment.ndfEnvironment = .mainnet
    environment.serviceList = .userDefaults(
      key: "preImage",
      userDefaults: UserDefaults(suiteName: "group.elixxir.messenger")!
    )
    environment.udEnvironment = .init(
      address: AlternativeUDConstants.address,
      cert: AlternativeUDConstants.cert.data(using: .utf8)!,
      contact: AlternativeUDConstants.contact.data(using: .utf8)!
    )
    container.register(Messenger.live(environment))

    container.register(Voxophone())
    container.register(BackupService())
    container.register(MakeAppScreenshot.live)
    container.register(FetchBannedList.live)
    container.register(ProcessBannedList.live)
    container.register(MakeReportDrawer.live)

    // MARK: Isolated

    container.register(HUDController())
    container.register(ToastController())
    container.register(StatusBarStylist())
  }
}

extension PasswordStorage {
  static let keychain: PasswordStorage = {
    let keychain = KeychainAccess.Keychain(
      service: "XXM"
    )
    return PasswordStorage(
      save: { password in keychain[data: "password"] = password},
      load: { try keychain[data: "password"] ?? { throw MissingPasswordError() }() },
      remove: { try keychain.remove("password") }
    )
  }()
}

private enum AlternativeUDConstants {
  static let address = "46.101.98.49:18001"
  static let cert = """
-----BEGIN CERTIFICATE-----
MIIDbDCCAlSgAwIBAgIJAOUNtZneIYECMA0GCSqGSIb3DQEBBQUAMGgxCzAJBgNV
BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlDbGFyZW1vbnQx
GzAZBgNVBAoMElByaXZhdGVncml0eSBDb3JwLjETMBEGA1UEAwwKKi5jbWl4LnJp
cDAeFw0xOTAzMDUxODM1NDNaFw0yOTAzMDIxODM1NDNaMGgxCzAJBgNVBAYTAlVT
MRMwEQYDVQQIDApDYWxpZm9ybmlhMRIwEAYDVQQHDAlDbGFyZW1vbnQxGzAZBgNV
BAoMElByaXZhdGVncml0eSBDb3JwLjETMBEGA1UEAwwKKi5jbWl4LnJpcDCCASIw
DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPP0WyVkfZA/CEd2DgKpcudn0oDh
Dwsjmx8LBDWsUgQzyLrFiVigfUmUefknUH3dTJjmiJtGqLsayCnWdqWLHPJYvFfs
WYW0IGF93UG/4N5UAWO4okC3CYgKSi4ekpfw2zgZq0gmbzTnXcHF9gfmQ7jJUKSE
tJPSNzXq+PZeJTC9zJAb4Lj8QzH18rDM8DaL2y1ns0Y2Hu0edBFn/OqavBJKb/uA
m3AEjqeOhC7EQUjVamWlTBPt40+B/6aFJX5BYm2JFkRsGBIyBVL46MvC02MgzTT9
bJIJfwqmBaTruwemNgzGu7Jk03hqqS1TUEvSI6/x8bVoba3orcKkf9HsDjECAwEA
AaMZMBcwFQYDVR0RBA4wDIIKKi5jbWl4LnJpcDANBgkqhkiG9w0BAQUFAAOCAQEA
neUocN4AbcQAC1+b3To8u5UGdaGxhcGyZBlAoenRVdjXK3lTjsMdMWb4QctgNfIf
U/zuUn2mxTmF/ekP0gCCgtleZr9+DYKU5hlXk8K10uKxGD6EvoiXZzlfeUuotgp2
qvI3ysOm/hvCfyEkqhfHtbxjV7j7v7eQFPbvNaXbLa0yr4C4vMK/Z09Ui9JrZ/Z4
cyIkxfC6/rOqAirSdIp09EGiw7GM8guHyggE4IiZrDslT8V3xIl985cbCxSxeW1R
tgH4rdEXuVe9+31oJhmXOE9ux2jCop9tEJMgWg7HStrJ5plPbb+HmjoX3nBO04E5
6m52PyzMNV+2N21IPppKwA==
-----END CERTIFICATE-----
"""
  static let contact = """
<xxc(2)7mbKFLE201WzH4SGxAOpHjjehwztIV+KGifi5L/PYPcDkAZiB9kZo+Dl3Vc7dD2SdZCFMOJVgwqGzfYRDkjc8RGEllBqNxq2sRRX09iQVef0kJQUgJCHNCOcvm6Ki0JJwvjLceyFh36iwK8oLbhLgqEZY86UScdACTyBCzBIab3ob5mBthYc3mheV88yq5PGF2DQ+dEvueUm+QhOSfwzppAJA/rpW9Wq9xzYcQzaqc3ztAGYfm2BBAHS7HVmkCbvZ/K07Xrl4EBPGHJYq12tWAN/C3mcbbBYUOQXyEzbSl/mO7sL3ORr0B4FMuqCi8EdlD6RO52pVhY+Cg6roRH1t5Ng1JxPt8Mv1yyjbifPhZ5fLKwxBz8UiFORfk0/jnhwgm25LRHqtNRRUlYXLvhv0HhqyYTUt17WNtCLATSVbqLrFGdy2EGadn8mP+kQNHp93f27d/uHgBNNe7LpuYCJMdWpoG6bOqmHEftxt0/MIQA8fTtTm3jJzv+7/QjZJDvQIv0SNdp8HFogpuwde+GuS4BcY7v5xz+ArGWcRR63ct2z83MqQEn9ODr1/gAAAgA7szRpDDQIdFUQo9mkWg8xBA==xxc>
"""
}
