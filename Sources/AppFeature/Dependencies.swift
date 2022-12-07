import ScanFeature
import ChatFeature
import MenuFeature
import TermsFeature
import Dependencies
import AppNavigation
import BackupFeature
import DrawerFeature
import SearchFeature
import RestoreFeature
import ContactFeature
import WebsiteFeature
import ProfileFeature
import ChatListFeature
import SettingsFeature
import RequestsFeature
import ChatMoreFeature
import GroupDraftFeature
import OnboardingFeature
import CountryListFeature
import CreateGroupFeature
import ContactListFeature
import RetryMessageFeature
import RequestPermissionFeature

extension NavigatorKey: DependencyKey {
  public static let liveValue: Navigator = CombinedNavigator(
    PresentModalNavigator(),
    DismissModalNavigator(),
    PushNavigator(),
    PopToRootNavigator(),
    PopToNavigator(),
    SetStackNavigator(),
    OpenUpNavigator(),
    OpenLeftNavigator(),

    PresentPhotoLibraryNavigator(),
    PresentActivitySheetNavigator(),

    PresentChatMoreNavigator(
      ChatMoreController.init(_:_:_:)
    ),
    PresentRetryMessageNavigator(
      RetryMessageController.init(_:_:_:)
    ),
    PresentWebsiteNavigator(
      WebsiteController.init(_:)
    ),
    PresentCreateGroupNavigator(
      CreateGroupController.init(_:)
    ),
    PresentGroupDraftNavigator(
      GroupDraftController.init
    ),
    PresentMenuNavigator(
      MenuController.init(_:_:)
    ),
    PresentProfileNavigator(
      ProfileController.init
    ),
    PresentChatListNavigator(
      ChatListController.init
    ),
    PresentDrawerNavigator(
      DrawerController.init(_:)
    ),
    PresentScanNavigator(
      ScanContainerController.init
    ),
    PresentChatNavigator(
      SingleChatController.init(_:)
    ),
    PresentContactNavigator(
      ContactController.init(_:)
    ),
    PresentSettingsNavigator(
      SettingsMainController.init
    ),
    PresentSettingsBackupNavigator(
      BackupController.init
    ),
    PresentRestoreListNavigator(
      RestoreListController.init
    ),
    PresentContactListNavigator(
      ContactListController.init
    ),
    PresentGroupChatNavigator(
      GroupChatController.init(_:)
    ),
    PresentProfileEmailNavigator(
      ProfileEmailController.init
    ),
    PresentProfilePhoneNavigator(
      ProfilePhoneController.init
    ),
    PresentSearchNavigator(
      ChatListController.init,
      SearchContainerController.init(_:)
    ),
    PresentRequestsNavigator(
      RequestsContainerController.init
    ),
    PresentCountryListNavigator(
      CountryListController.init(_:)
    ),
    PresentOnboardingEmailNavigator(
      OnboardingEmailController.init
    ),
    PresentOnboardingPhoneNavigator(
      OnboardingPhoneController.init
    ),
    PresentProfileCodeNavigator(
      ProfileCodeController.init(_:_:_:)
    ),
    PresentOnboardingStartNavigator(
      OnboardingStartController.init
    ),
    PresentSettingsAdvancedNavigator(
      SettingsAdvancedController.init
    ),
    PresentTermsAndConditionsNavigator(
      TermsConditionsController.init
    ),
    PresentPermissionRequestNavigator(
      RequestPermissionController.init
    ),
    PresentOnboardingWelcomeNavigator(
      OnboardingWelcomeController.init
    ),
    PresentSettingsAccountDeleteNavigator(
      SettingsDeleteController.init
    ),
    PresentOnboardingUsernameNavigator(
      OnboardingUsernameController.init
    ),
    PresentOnboardingCodeNavigator(
      OnboardingCodeController.init(_:_:_:)
    )
  )
}

import LaunchFeature
import XXMessengerClient

private enum PushNotificationRouterKey: DependencyKey {
  static var liveValue = Stored<PushNotificationRouter?>.inMemory()
  static var testValue = Stored<PushNotificationRouter?>.unimplemented()
}

extension DependencyValues {
  public var pushNotificationRouter: Stored<PushNotificationRouter?> {
    get { self[PushNotificationRouterKey.self] }
    set { self[PushNotificationRouterKey.self] = newValue }
  }
}
