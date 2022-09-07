// MARK: SDK

import UIKit
import Network
import QuickLook
import MobileCoreServices

// MARK: Isolated features

import HUD
import Theme
import Bindings
import XXLogger
import Keychain
import Defaults
import Countries
import Voxophone
import Permissions
import PushFeature
import SFTPFeature
import CrashService
import ToastFeature
import iCloudFeature
import CrashReporting
import NetworkMonitor
import DropboxFeature
import VersionChecking
import ReportingFeature
import GoogleDriveFeature
import DependencyInjection

// MARK: UI Features

import ScanFeature
import ChatFeature
import MenuFeature
import TermsFeature
import BackupFeature
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

import KeychainAccess
import XXClient

struct DependencyRegistrator {
    static private let container = DependencyInjection.Container.shared

    // MARK: MOCK

    static func registerForMock() {
        container.register(XXLogger.noop)
        container.register(CrashReporter.noop)
        container.register(VersionChecker.mock)
        container.register(ReportingStatus.mock())
        container.register(SendReport.mock())
        container.register(MockNetworkMonitor() as NetworkMonitoring)
        container.register(KeyObjectStore.userDefaults)
        container.register(MockPushHandler() as PushHandling)
        container.register(MockKeychainHandler() as KeychainHandling)
        container.register(MockPermissionHandler() as PermissionHandling)

        /// Restore / Backup

        container.register(SFTPService.mock)
        container.register(iCloudServiceMock() as iCloudInterface)
        container.register(DropboxServiceMock() as DropboxInterface)
        container.register(GoogleDriveServiceMock() as GoogleDriveInterface)

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
        container.register(CrashReporter.live)
        container.register(VersionChecker.live())
        container.register(ReportingStatus.live())
        container.register(SendReport.live)

        container.register(NetworkMonitor() as NetworkMonitoring)
        container.register(PushHandler() as PushHandling)
        container.register(KeychainHandler() as KeychainHandling)
        container.register(PermissionHandler() as PermissionHandling)

        /// Restore / Backup

        container.register(SFTPService.live)
        container.register(iCloudService() as iCloudInterface)
        container.register(DropboxService() as DropboxInterface)
        container.register(GoogleDriveService() as GoogleDriveInterface)

        registerCommonDependencies()
    }

    // MARK: COMMON

    static private func registerCommonDependencies() {
        container.register(Voxophone())
        container.register(BackupService())
        container.register(MakeAppScreenshot.live)
        container.register(FetchBannedList.live)
        container.register(ProcessBannedList.live)
        container.register(MakeReportDrawer.live)

        // MARK: Isolated

        container.register(HUD())
        container.register(ThemeController() as ThemeControlling)
        container.register(ToastController())
        container.register(StatusBarController() as StatusBarStyleControlling)

        // MARK: Coordinators

        container.register(
            TermsCoordinator.live(
                usernameFactory: OnboardingUsernameController.init,
                chatListFactory: ChatListController.init
            )
        )

        container.register(
            LaunchCoordinator(
                termsFactory: TermsConditionsController.init,
                searchFactory: SearchContainerController.init,
                requestsFactory: RequestsContainerController.init,
                chatListFactory: ChatListController.init,
                onboardingFactory: OnboardingStartController.init,
                singleChatFactory: SingleChatController.init(_:),
                groupChatFactory: GroupChatController.init(_:)
            ) as LaunchCoordinating)

        container.register(
            BackupCoordinator(
                passphraseFactory: BackupPassphraseController.init(_:_:)
            ) as BackupCoordinating)

        container.register(
            MenuCoordinator(
                scanFactory: ScanContainerController.init,
                chatsFactory: ChatListController.init,
                profileFactory: ProfileController.init,
                settingsFactory: SettingsController.init,
                contactsFactory: ContactListController.init,
                requestsFactory: RequestsContainerController.init
            ) as MenuCoordinating)

        container.register(
            SearchCoordinator(
                contactsFactory: ContactListController.init,
                requestsFactory: RequestsContainerController.init,
                contactFactory: ContactController.init(_:),
                countriesFactory: CountryListController.init(_:)
            ) as SearchCoordinating)

        container.register(
            ProfileCoordinator(
                emailFactory: ProfileEmailController.init,
                phoneFactory: ProfilePhoneController.init,
                imagePickerFactory: UIImagePickerController.init,
                permissionFactory: RequestPermissionController.init,
                sideMenuFactory: MenuController.init(_:_:),
                countriesFactory: CountryListController.init(_:),
                codeFactory: ProfileCodeController.init(_:_:)
            ) as ProfileCoordinating)

        container.register(
            SettingsCoordinator(
                backupFactory: BackupController.init,
                advancedFactory: SettingsAdvancedController.init,
                accountDeleteFactory: AccountDeleteController.init,
                sideMenuFactory: MenuController.init(_:_:)
            ) as SettingsCoordinating)

        container.register(
            RestoreCoordinator(
                successFactory: RestoreSuccessController.init,
                chatListFactory: ChatListController.init,
                restoreFactory: RestoreController.init(_:),
                passphraseFactory: RestorePassphraseController.init(_:)
            ) as RestoreCoordinating)

        container.register(
            ChatCoordinator(
                retryFactory: RetrySheetController.init,
                webFactory: WebScreen.init(url:),
                previewFactory: QLPreviewController.init,
                contactFactory: ContactController.init(_:),
                imagePickerFactory: UIImagePickerController.init,
                permissionFactory: RequestPermissionController.init
            ) as ChatCoordinating)

        container.register(
            ContactCoordinator(
                requestsFactory: RequestsContainerController.init,
                singleChatFactory: SingleChatController.init(_:),
                imagePickerFactory: UIImagePickerController.init,
                nicknameFactory: NicknameController.init(_:_:)
            ) as ContactCoordinating)

        container.register(
            RequestsCoordinator(
                searchFactory: SearchContainerController.init,
                contactFactory: ContactController.init(_:),
                singleChatFactory: SingleChatController.init(_:),
                groupChatFactory: GroupChatController.init(_:),
                sideMenuFactory: MenuController.init(_:_:),
                nicknameFactory: NicknameController.init(_:_:)
            ) as RequestsCoordinating)

        container.register(
            OnboardingCoordinator(
                emailFactory: OnboardingEmailController.init,
                phoneFactory: OnboardingPhoneController.init,
                searchFactory: SearchContainerController.init,
                welcomeFactory: OnboardingWelcomeController.init,
                chatListFactory: ChatListController.init,
                termsFactory: TermsConditionsController.init,
                usernameFactory: OnboardingUsernameController.init,
                restoreListFactory: RestoreListController.init,
                successFactory: OnboardingSuccessController.init(_:),
                countriesFactory: CountryListController.init(_:),
                phoneConfirmationFactory: OnboardingPhoneConfirmationController.init(_:_:),
                emailConfirmationFactory: OnboardingEmailConfirmationController.init(_:_:)
            ) as OnboardingCoordinating)

        container.register(
            ContactListCoordinator(
                scanFactory: ScanContainerController.init,
                searchFactory: SearchContainerController.init,
                newGroupFactory: CreateGroupController.init,
                requestsFactory: RequestsContainerController.init,
                contactFactory: ContactController.init(_:),
                singleChatFactory: SingleChatController.init(_:),
                groupChatFactory: GroupChatController.init(_:),
                sideMenuFactory: MenuController.init(_:_:),
                groupDrawerFactory: CreateDrawerController.init(_:_:)
            ) as ContactListCoordinating)

        container.register(
            ScanCoordinator(
                emailFactory: ProfileEmailController.init,
                phoneFactory: ProfilePhoneController.init,
                contactsFactory: ContactListController.init,
                requestsFactory: RequestsContainerController.init,
                contactFactory: ContactController.init(_:),
                sideMenuFactory: MenuController.init(_:_:)
            ) as ScanCoordinating)


        container.register(
            ChatListCoordinator(
                scanFactory: ScanContainerController.init,
                searchFactory: SearchContainerController.init,
                newGroupFactory: CreateGroupController.init,
                contactsFactory: ContactListController.init,
                contactFactory: ContactController.init(_:),
                singleChatFactory: SingleChatController.init(_:),
                groupChatFactory: GroupChatController.init(_:),
                sideMenuFactory: MenuController.init(_:_:)
            ) as ChatListCoordinating)
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
