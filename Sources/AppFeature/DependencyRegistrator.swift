// MARK: SDK

import UIKit
import Network
import QuickLook
import MobileCoreServices

// MARK: Isolated features

import Bindings
import Keychain
import Defaults
import Voxophone
import PushFeature
import CrashReporting
import VersionChecking
import ReportingFeature
import CountryListFeature

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
import WebsiteFeature
import ProfileFeature
import ChatListFeature
import SettingsFeature
import RequestsFeature
import GroupDraftFeature
import OnboardingFeature
import CreateGroupFeature
import ContactListFeature
import RequestPermissionFeature

import Shared
import XXClient
import AppNavigation
import KeychainAccess
import XXMessengerClient

import ComposableArchitecture

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
