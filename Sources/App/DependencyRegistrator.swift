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
import Integration
import Permissions
import PushFeature
import CrashService
import ToastFeature
import iCloudFeature
import CrashReporting
import NetworkMonitor
import DropboxFeature
import VersionChecking
import GoogleDriveFeature
import DependencyInjection

// MARK: UI Features

import ScanFeature
import ChatFeature
import MenuFeature
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

struct DependencyRegistrator {
    static private let container = DependencyInjection.Container.shared

    // MARK: MOCK

    static func registerForMock() {
        container.register(XXLogger.noop)
        container.register(CrashReporter.noop)
        container.register(VersionChecker.mock)
        container.register(XXNetwork<BindingsMock>() as XXNetworking)
        container.register(MockNetworkMonitor() as NetworkMonitoring)
        container.register(KeyObjectStore.userDefaults)
        container.register(MockPushHandler() as PushHandling)
        container.register(MockKeychainHandler() as KeychainHandling)
        container.register(MockPermissionHandler() as PermissionHandling)

        /// Restore / Backup

        container.register(iCloudServiceMock() as iCloudInterface)
        container.register(DropboxServiceMock() as DropboxInterface)
        container.register(GoogleDriveServiceMock() as GoogleDriveInterface)

        registerCommonDependencies()
    }

    // MARK: LIVE

    static func registerForLive() {
        container.register(KeyObjectStore.userDefaults)
        container.register(XXLogger.live())
        container.register(CrashReporter.live)
        container.register(VersionChecker.live())

        container.register(XXNetwork<BindingsClient>() as XXNetworking)
        container.register(NetworkMonitor() as NetworkMonitoring)
        container.register(PushHandler() as PushHandling)
        container.register(KeychainHandler() as KeychainHandling)
        container.register(PermissionHandler() as PermissionHandling)

        /// Restore / Backup

        container.register(iCloudService() as iCloudInterface)
        container.register(DropboxService() as DropboxInterface)
        container.register(GoogleDriveService() as GoogleDriveInterface)

        registerCommonDependencies()
    }

    // MARK: COMMON

    static private func registerCommonDependencies() {
        container.register(Voxophone())
        container.register(BackupService())

        // MARK: Isolated

        container.register(HUD() as HUDType)
        container.register(ThemeController() as ThemeControlling)
        container.register(ToastController())
        container.register(StatusBarController() as StatusBarStyleControlling)

        // MARK: Coordinators

        container.register(
            LaunchCoordinator(
                requestsFactory: RequestsContainerController.init,
                chatListFactory: ChatListController.init,
                onboardingFactory: OnboardingStartController.init(_:),
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
                restoreFactory: RestoreController.init(_:_:),
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
                searchFactory: SearchController.init,
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
                searchFactory: SearchController.init,
                welcomeFactory: OnboardingWelcomeController.init,
                chatListFactory: ChatListController.init,
                usernameFactory: OnboardingUsernameController.init(_:),
                restoreListFactory: RestoreListController.init(_:),
                successFactory: OnboardingSuccessController.init(_:),
                countriesFactory: CountryListController.init(_:),
                phoneConfirmationFactory: OnboardingPhoneConfirmationController.init(_:_:),
                emailConfirmationFactory: OnboardingEmailConfirmationController.init(_:_:)
            ) as OnboardingCoordinating)

        container.register(
            ContactListCoordinator(
                scanFactory: ScanContainerController.init,
                searchFactory: SearchController.init,
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
                searchFactory: SearchController.init,
                newGroupFactory: CreateGroupController.init,
                contactsFactory: ContactListController.init,
                contactFactory: ContactController.init(_:),
                singleChatFactory: SingleChatController.init(_:),
                groupChatFactory: GroupChatController.init(_:),
                sideMenuFactory: MenuController.init(_:_:)
            ) as ChatListCoordinating)
    }
}

extension PushRouter {
    static func live(navigationController: UINavigationController) -> PushRouter {
        PushRouter { route, completion in
            if let launchController = navigationController.viewControllers.last as? LaunchController {
                launchController.pendingPushRoute = route
            } else {
                switch route {
                case .requests:
                    if (navigationController.viewControllers.last as? RequestsContainerController) == nil {
                        navigationController.setViewControllers([RequestsContainerController()], animated: true)
                    }
                case .contactChat(id: let id):
                    if let session = try? DependencyInjection.Container.shared.resolve() as SessionType,
                       let contact = try? session.dbManager.fetchContacts(.init(id: [id])).first {
                        navigationController.setViewControllers([
                            ChatListController(),
                            SingleChatController(contact)
                        ], animated: true)
                    }
                case .groupChat(id: let id):
                    if let session = try? DependencyInjection.Container.shared.resolve() as SessionType,
                       let info = try? session.dbManager.fetchGroupInfos(.init(groupId: id)).first {
                        navigationController.setViewControllers([
                            ChatListController(),
                            GroupChatController(info)
                        ], animated: true)
                    }
                }
            }

            completion()
        }
    }
}
