// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "client-ios",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "App", targets: ["App"]),
        .library(name: "HUD", targets: ["HUD"]),
        .library(name: "Theme", targets: ["Theme"]),
        .library(name: "Shared", targets: ["Shared"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "XXLogger", targets: ["XXLogger"]),
        .library(name: "Defaults", targets: ["Defaults"]),
        .library(name: "Keychain", targets: ["Keychain"]),
        .library(name: "Voxophone", targets: ["Voxophone"]),
        .library(name: "Countries", targets: ["Countries"]),
        .library(name: "InputField", targets: ["InputField"]),
        .library(name: "TestHelpers", targets: ["TestHelpers"]),
        .library(name: "ScanFeature", targets: ["ScanFeature"]),
        .library(name: "Permissions", targets: ["Permissions"]),
        .library(name: "MenuFeature", targets: ["MenuFeature"]),
        .library(name: "ChatFeature", targets: ["ChatFeature"]),
        .library(name: "PushFeature", targets: ["PushFeature"]),
        .library(name: "SFTPFeature", targets: ["SFTPFeature"]),
        .library(name: "CrashService", targets: ["CrashService"]),
        .library(name: "TermsFeature", targets: ["TermsFeature"]),
        .library(name: "Presentation", targets: ["Presentation"]),
        .library(name: "ToastFeature", targets: ["ToastFeature"]),
        .library(name: "BackupFeature", targets: ["BackupFeature"]),
        .library(name: "LaunchFeature", targets: ["LaunchFeature"]),
        .library(name: "iCloudFeature", targets: ["iCloudFeature"]),
        .library(name: "SearchFeature", targets: ["SearchFeature"]),
        .library(name: "DrawerFeature", targets: ["DrawerFeature"]),
        .library(name: "CollectionView", targets: ["CollectionView"]),
        .library(name: "RestoreFeature", targets: ["RestoreFeature"]),
        .library(name: "CrashReporting", targets: ["CrashReporting"]),
        .library(name: "ProfileFeature", targets: ["ProfileFeature"]),
        .library(name: "ContactFeature", targets: ["ContactFeature"]),
        .library(name: "NetworkMonitor", targets: ["NetworkMonitor"]),
        .library(name: "DropboxFeature", targets: ["DropboxFeature"]),
        .library(name: "VersionChecking", targets: ["VersionChecking"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        .library(name: "ChatListFeature", targets: ["ChatListFeature"]),
        .library(name: "RequestsFeature", targets: ["RequestsFeature"]),
        .library(name: "ChatInputFeature", targets: ["ChatInputFeature"]),
        .library(name: "OnboardingFeature", targets: ["OnboardingFeature"]),
        .library(name: "GoogleDriveFeature", targets: ["GoogleDriveFeature"]),
        .library(name: "ContactListFeature", targets: ["ContactListFeature"]),
        .library(name: "DependencyInjection", targets: ["DependencyInjection"]),
        .library(name: "ReportingFeature", targets: ["ReportingFeature"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Quick/Quick",
            .upToNextMajor(from: "3.0.0")
        ),
        .package(
            url: "https://github.com/Quick/Nimble",
            .upToNextMajor(from: "9.0.0")
        ),
        .package(
            url: "https://github.com/SnapKit/SnapKit",
            .upToNextMajor(from: "5.0.1")
        ),
        .package(
            url: "https://github.com/icanzilb/Retry.git",
            .upToNextMajor(from: "0.6.3")
        ),
        .package(
            url: "https://github.com/ekazaev/ChatLayout",
            .upToNextMajor(from: "1.1.14")
        ),
        .package(
            url: "https://github.com/ra1028/DifferenceKit",
            .upToNextMajor(from: "1.2.0")
        ),
        .package(
            url: "https://github.com/apple/swift-protobuf",
            .upToNextMajor(from: "1.14.0")
        ),
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS",
            .upToNextMajor(from: "6.1.0")
        ),
        .package(
            url: "https://github.com/dropbox/SwiftyDropbox.git",
            .upToNextMajor(from: "8.2.1")
        ),
        .package(
            url: "https://github.com/amosavian/FileProvider.git",
            .upToNextMajor(from: "0.26.0")
        ),
        .package(
            url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git",
            .upToNextMajor(from: "1.9.5")
        ),
        .package(
            url: "https://github.com/darrarski/ScrollViewController",
            .upToNextMajor(from: "1.2.0")
        ),
        .package(
            url: "https://github.com/pointfreeco/combine-schedulers",
            .upToNextMajor(from: "0.5.0")
        ),
        .package(
            url: "https://github.com/kishikawakatsumi/KeychainAccess",
            .upToNextMajor(from: "4.2.1")
        ),
        .package(
            url: "https://github.com/google/google-api-objectivec-client-for-rest",
            .upToNextMajor(from: "1.6.0")
        ),
        .package(
//            path: "../elixxir-dapps-sdk-swift"
            url: "https://git.xx.network/elixxir/elixxir-dapps-sdk-swift",
            branch: "development"
        ),
        .package(
            url: "https://git.xx.network/elixxir/client-ios-db.git",
            .upToNextMajor(from: "1.1.0")
        ),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "8.10.0")
        ),
        .package(
            url: "https://github.com/darrarski/Shout.git",
            revision: "df5a662293f0ac15eeb4f2fd3ffd0c07b73d0de0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            .upToNextMajor(from: "0.32.0")
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-custom-dump.git",
            .upToNextMajor(from: "0.5.0")
        ),
        .package(
            url: "https://github.com/swiftcsv/SwiftCSV.git",
            from: "0.8.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git",
            .upToNextMajor(from: "0.3.3")
        ),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .target(name: "Keychain"),
                .target(name: "Voxophone"),
                .target(name: "Permissions"),
                .target(name: "ScanFeature"),
                .target(name: "ChatFeature"),
                .target(name: "MenuFeature"),
                .target(name: "PushFeature"),
                .target(name: "SFTPFeature"),
                .target(name: "TermsFeature"),
                .target(name: "ToastFeature"),
                .target(name: "CrashService"),
                .target(name: "BackupFeature"),
                .target(name: "SearchFeature"),
                .target(name: "LaunchFeature"),
                .target(name: "iCloudFeature"),
                .target(name: "DropboxFeature"),
                .target(name: "ContactFeature"),
                .target(name: "RestoreFeature"),
                .target(name: "ProfileFeature"),
                .target(name: "CrashReporting"),
                .target(name: "ChatListFeature"),
                .target(name: "SettingsFeature"),
                .target(name: "RequestsFeature"),
                .target(name: "ReportingFeature"),
                .target(name: "OnboardingFeature"),
                .target(name: "GoogleDriveFeature"),
                .target(name: "ContactListFeature"),
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
            ]
        ),
        .target(
            name: "CrashReporting"
        ),
        .target(
            name: "NetworkMonitor",
            dependencies: [
                .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
            ]
        ),
        .target(
            name: "VersionChecking"
        ),
        .target(
            name: "DependencyInjection"
        ),
        .testTarget(
            name: "DependencyInjectionTests",
            dependencies: [
                .target(name: "DependencyInjection"),
            ]
        ),
        .target(
            name: "InputField",
            dependencies: [
                .target(name: "Shared"),
            ]
        ),
        .target(
            name: "Permissions",
            dependencies: [
                .target(name: "Theme"),
                .target(name: "Shared"),
                .target(name: "DependencyInjection"),
            ]
        ),
        .target(
            name: "PushFeature",
            dependencies: [
                .target(name: "Models"),
                .target(name: "Defaults"),
                .target(name: "ReportingFeature"),
                .target(name: "DependencyInjection"),
                .product(name: "XXDatabase", package: "client-ios-db"),
                .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
                .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
            ]
        ),
        .target(
            name: "TestHelpers",
            dependencies: [
                .target(name: "Models"),
                .target(name: "Presentation"),
            ]
        ),
        .target(
            name: "Keychain",
            dependencies: [
                .product(name: "KeychainAccess", package: "KeychainAccess"),
            ]
        ),
        .target(
            name: "Voxophone",
            dependencies: [
                .target(name: "Shared"),
            ]
        ),
        .target(
            name: "Models",
            dependencies: [
                .product(name: "DifferenceKit", package: "DifferenceKit"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ]
        ),
        .target(
            name: "Defaults",
            dependencies: [
                .target(name: "DependencyInjection"),
            ]
        ),
        .target(
            name: "ToastFeature",
            dependencies: [
                .target(name: "Shared"),
            ]
        ),
        .target(
            name: "CrashService",
            dependencies: [
                .target(name: "CrashReporting"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
            ]
        ),
        .target(
            name: "SFTPFeature",
            dependencies: [
                .target(name: "HUD"),
                .target(name: "Models"),
                .target(name: "Shared"),
                .target(name: "Keychain"),
                .target(name: "InputField"),
                .target(name: "Presentation"),
                .target(name: "DependencyInjection"),
                .product(name: "Shout", package: "Shout"),
            ]
        ),
        .target(
            name: "GoogleDriveFeature",
            dependencies: [
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleAPIClientForREST_Drive", package: "google-api-objectivec-client-for-rest"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "iCloudFeature",
            dependencies: [
                .product(name: "FilesProvider", package: "FileProvider"),
            ]
        ),
        .target(
            name: "DropboxFeature",
            dependencies: [
                .product(name: "SwiftyDropbox", package: "SwiftyDropbox"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "Countries",
            dependencies: [
                .target(name: "Theme"),
                .target(name: "Shared"),
                .target(name: "DependencyInjection"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "Theme",
            dependencies: [
                .target(name: "Defaults"),
                .target(name: "DependencyInjection"),
            ]
        ),
        .testTarget(
            name: "ThemeTests",
            dependencies: [
                .target(name: "Theme"),
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .target(
            name: "DrawerFeature",
            dependencies: [
                .target(name: "Shared"),
                .target(name: "InputField"),
                .product(name: "ScrollViewController", package: "ScrollViewController"),
            ]
        ),
        .target(
            name: "HUD",
            dependencies: [
                .target(name: "Theme"),
                .target(name: "Shared"),
                .product(name: "SnapKit", package: "SnapKit"),
            ]
        ),
        .target(
            name: "XXLogger",
            dependencies: [
                .product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
            ]
        ),
        .target(
            name: "Shared",
            dependencies: [
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "ChatLayout", package: "ChatLayout"),
                .product(name: "DifferenceKit", package: "DifferenceKit"),
            ],
            exclude: [
                "swiftgen.yml",
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "Presentation",
            dependencies: [
                .target(name: "Theme"),
                .target(name: "Shared"),
                .product(name: "SnapKit", package: "SnapKit"),
            ]
        ),
        .testTarget(
            name: "PresentationTests",
            dependencies: [
                .target(name: "Presentation"),
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .target(
            name: "ChatInputFeature",
            dependencies: [
                .target(name: "Voxophone"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "RestoreFeature",
            dependencies: [
                .target(name: "HUD"),
                .target(name: "Shared"),
                .target(name: "SFTPFeature"),
                .target(name: "Presentation"),
                .target(name: "iCloudFeature"),
                .target(name: "BackupFeature"),
                .target(name: "DropboxFeature"),
                .target(name: "GoogleDriveFeature"),
                .target(name: "DependencyInjection"),
                .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
            ]
        ),
        .target(
            name: "ContactFeature",
            dependencies: [
                .target(name: "Shared"),
                .target(name: "InputField"),
                .target(name: "ChatFeature"),
                .target(name: "Presentation"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "ScrollViewController", package: "ScrollViewController"),
            ]
        ),
        .testTarget(
            name: "ContactFeatureTests",
            dependencies: [
                .target(name: "TestHelpers"),
                .target(name: "ContactFeature"),
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .target(
            name: "ChatFeature",
            dependencies: [
                .target(name: "HUD"),
                .target(name: "Theme"),
                .target(name: "Shared"),
                .target(name: "Defaults"),
                .target(name: "Keychain"),
                .target(name: "Voxophone"),
                .target(name: "Permissions"),
                .target(name: "Presentation"),
                .target(name: "DrawerFeature"),
                .target(name: "ChatInputFeature"),
                .target(name: "ReportingFeature"),
                .target(name: "DependencyInjection"),
                .product(name: "ChatLayout", package: "ChatLayout"),
                .product(name: "DifferenceKit", package: "DifferenceKit"),
                .product(name: "ScrollViewController", package: "ScrollViewController"),
                .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
                .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
            ]
        ),
        .testTarget(
            name: "ChatFeatureTests",
            dependencies: [
                .target(name: "ChatFeature"),
                .target(name: "TestHelpers"),
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .target(
            name: "SearchFeature",
            dependencies: [
                .target(name: "HUD"),
                .target(name: "Shared"),
                .target(name: "Countries"),
                .target(name: "PushFeature"),
                .target(name: "Presentation"),
                .target(name: "ContactFeature"),
                .target(name: "NetworkMonitor"),
                .target(name: "DependencyInjection"),
                .product(name: "Retry", package: "Retry"),
                .product(name: "XXDatabase", package: "client-ios-db"),
            ]
        ),
        .testTarget(
            name: "SearchFeatureTests",
            dependencies: [
                .target(name: "TestHelpers"),
                .target(name: "SearchFeature"),
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .target(
            name: "LaunchFeature",
            dependencies: [
                .target(name: "HUD"),
                .target(name: "Theme"),
                .target(name: "Shared"),
                .target(name: "Defaults"),
                .target(name: "PushFeature"),
                .target(name: "Permissions"),
                .target(name: "DropboxFeature"),
                .target(name: "VersionChecking"),
                .target(name: "ReportingFeature"),
                .target(name: "DependencyInjection"),
                .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
                .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "XXLegacyDatabaseMigrator", package: "client-ios-db"),
            ]
        ),
        .target(
            name: "TermsFeature",
            dependencies: [
                .target(name: "Theme"),
                .target(name: "Shared"),
                .target(name: "Defaults"),
                .target(name: "Presentation"),
            ]
        ),
        .target(
            name: "RequestsFeature",
            dependencies: [
                .target(name: "Theme"),
                .target(name: "Shared"),
                .target(name: "ToastFeature"),
                .target(name: "ContactFeature"),
                .target(name: "DependencyInjection"),
                .product(name: "DifferenceKit", package: "DifferenceKit"),
            ]
        ),
        .testTarget(
            name: "RequestsFeatureTests",
            dependencies: [
                .target(name: "TestHelpers"),
                .target(name: "RequestsFeature"),
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .target(
            name: "ProfileFeature",
            dependencies: [
                .target(name: "HUD"),
                .target(name: "Theme"),
                .target(name: "Shared"),
                .target(name: "Keychain"),
                .target(name: "Defaults"),
                .target(name: "Countries"),
                .target(name: "InputField"),
                .target(name: "MenuFeature"),
                .target(name: "Permissions"),
                .target(name: "Presentation"),
                .target(name: "DrawerFeature"),
                .target(name: "BackupFeature"),
                .target(name: "DependencyInjection"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "ScrollViewController", package: "ScrollViewController"),
                .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
                .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
            ]
        ),
        .testTarget(
            name: "ProfileFeatureTests",
            dependencies: [
                .target(name: "TestHelpers"),
                .target(name: "ProfileFeature"),
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .target(
            name: "ChatListFeature",
            dependencies: [
                .target(name: "Theme"),
                .target(name: "Shared"),
                .target(name: "Defaults"),
                .target(name: "MenuFeature"),
                .target(name: "ChatFeature"),
                .target(name: "ProfileFeature"),
                .target(name: "SettingsFeature"),
                .target(name: "ContactListFeature"),
                .target(name: "DependencyInjection"),
                .product(name: "DifferenceKit", package: "DifferenceKit"),
            ]
        ),
        .testTarget(
            name: "ChatListFeatureTests",
            dependencies: [
                .target(name: "TestHelpers"),
                .target(name: "ChatListFeature"),
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .target(
            name: "OnboardingFeature",
            dependencies: [
                .target(name: "HUD"),
                .target(name: "Shared"),
                .target(name: "Defaults"),
                .target(name: "Keychain"),
                .target(name: "Countries"),
                .target(name: "InputField"),
                .target(name: "Permissions"),
                .target(name: "PushFeature"),
                .target(name: "Presentation"),
                .target(name: "DrawerFeature"),
                .target(name: "VersionChecking"),
                .target(name: "DependencyInjection"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "ScrollViewController", package: "ScrollViewController"),
            ]
        ),
        .testTarget(
            name: "OnboardingFeatureTests",
            dependencies: [
                .target(name: "TestHelpers"),
                .target(name: "OnboardingFeature"),
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .target(
            name: "MenuFeature",
            dependencies: [
                .target(name: "Theme"),
                .target(name: "Shared"),
                .target(name: "Defaults"),
                .target(name: "Presentation"),
                .target(name: "DrawerFeature"),
                .target(name: "ReportingFeature"),
                .target(name: "DependencyInjection"),
                .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
            ]
        ),
        .target(
            name: "BackupFeature",
            dependencies: [
                .target(name: "HUD"),
                .target(name: "Shared"),
                .target(name: "Models"),
                .target(name: "InputField"),
                .target(name: "SFTPFeature"),
                .target(name: "Presentation"),
                .target(name: "iCloudFeature"),
                .target(name: "DrawerFeature"),
                .target(name: "DropboxFeature"),
                .target(name: "GoogleDriveFeature"),
                .target(name: "DependencyInjection"),
            ]
        ),
        .target(
            name: "ScanFeature",
            dependencies: [
                .target(name: "Theme"),
                .target(name: "Shared"),
                .target(name: "Countries"),
                .target(name: "Permissions"),
                .target(name: "Presentation"),
                .target(name: "ContactFeature"),
                .target(name: "NetworkMonitor"),
                .target(name: "DependencyInjection"),
                .product(name: "SnapKit", package: "SnapKit"),
            ]
        ),
        .testTarget(
            name: "ScanFeatureTests",
            dependencies: [
                .target(name: "ScanFeature"),
                .target(name: "TestHelpers"),
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .target(
            name: "ContactListFeature",
            dependencies: [
                .target(name: "Theme"),
                .target(name: "Shared"),
                .target(name: "Presentation"),
                .target(name: "ContactFeature"),
                .target(name: "DependencyInjection"),
                .product(name: "DifferenceKit", package: "DifferenceKit"),
            ]
        ),
        .testTarget(
            name: "ContactListFeatureTests",
            dependencies: [
                .target(name: "TestHelpers"),
                .target(name: "ContactListFeature"),
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .target(
            name: "SettingsFeature",
            dependencies: [
                .target(name: "HUD"),
                .target(name: "Theme"),
                .target(name: "Shared"),
                .target(name: "Defaults"),
                .target(name: "Keychain"),
                .target(name: "XXLogger"),
                .target(name: "InputField"),
                .target(name: "PushFeature"),
                .target(name: "Permissions"),
                .target(name: "MenuFeature"),
                .target(name: "Presentation"),
                .target(name: "DrawerFeature"),
                .target(name: "DependencyInjection"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "ScrollViewController", package: "ScrollViewController"),
            ]
        ),
        .testTarget(
            name: "SettingsFeatureTests",
            dependencies: [
                .target(name: "TestHelpers"),
                .target(name: "SettingsFeature"),
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .target(
            name: "CollectionView",
            dependencies: [
                .product(name: "ChatLayout", package: "ChatLayout"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
            ]
        ),
        .testTarget(
            name: "CollectionViewTests",
            dependencies: [
                .target(name: "CollectionView"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]
        ),
        .target(
            name: "ReportingFeature",
            dependencies: [
                .target(name: "DrawerFeature"),
                .target(name: "Shared"),
                .product(name: "SwiftCSV", package: "SwiftCSV"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
