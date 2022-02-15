// MARK: SDK

import Network

// MARK: Isolated features

import HUD
import Theme
import Bindings
import XXLogger
import Keychain
import Defaults
import Integration
import Permissions
import CrashService
import CrashReporting
import NetworkMonitor
import VersionChecking
import PushNotifications
import DependencyInjection
import Voxophone

// MARK: UI Features

import ScanFeature
import ChatFeature
import MenuFeature
import SearchFeature
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
        registerCommonDependencies()
    }

    // MARK: LIVE

    static func registerForLive() {
        container.register(XXLogger.live())
        container.register(CrashReporter.live)
        container.register(VersionChecker.live())
        container.register(XXNetwork<BindingsClient>() as XXNetworking)
        container.register(NetworkMonitor() as NetworkMonitoring)
        container.register(KeyObjectStore.userDefaults)
        container.register(PushHandler() as PushHandling)
        container.register(KeychainHandler() as KeychainHandling)
        container.register(PermissionHandler() as PermissionHandling)
        registerCommonDependencies()
    }

    // MARK: COMMON

    static private func registerCommonDependencies() {
        container.register(Voxophone())

        // MARK: Isolated

        container.register(HUD() as HUDType)
        container.register(ThemeController() as ThemeControlling)
        container.register(StatusBarController() as StatusBarStyleControlling)

        // MARK: Coordinators

        container.register(SearchCoordinator() as SearchCoordinating)
        container.register(ProfileCoordinator() as ProfileCoordinating)
        container.register(SettingsCoordinator() as SettingsCoordinating)

        container.register(
            ChatCoordinator(
                retryFactory: RetrySheetController.init,
                contactFactory: ContactController.init(_:)
            ) as ChatCoordinating)

        container.register(
            ContactCoordinator(
                requestsFactory: RequestsContainerController.init
            ) as ContactCoordinating)

        container.register(
            RequestsCoordinator(
                searchFactory: SearchController.init
            ) as RequestsCoordinating)

        container.register(
            OnboardingCoordinator(
                chatListFactory: ChatListController.init
            ) as OnboardingCoordinating)

        container.register(
            ContactListCoordinator(
                scanFactory: ScanContainerController.init,
                searchFactory: SearchController.init,
                newGroupFactory: CreateGroupController.init,
                requestsFactory: RequestsContainerController.init
            ) as ContactListCoordinating)

        container.register(
            ScanCoordinator(
                contactsFactory: ContactListController.init,
                requestsFactory: RequestsContainerController.init
            ) as ScanCoordinating)

        container.register(
            ChatListCoordinator(
                scanFactory: ScanContainerController.init,
                searchFactory: SearchController.init,
                profileFactory: ProfileController.init,
                settingsFactory: SettingsController.init,
                contactsFactory: ContactListController.init,
                requestsFactory: RequestsContainerController.init
            ) as ChatListCoordinating)
    }
}
