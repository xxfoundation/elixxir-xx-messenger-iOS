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
        .library(name: "Bindings", targets: ["Bindings"]),
        .library(name: "Keychain", targets: ["Keychain"]),
        .library(name: "Voxophone", targets: ["Voxophone"]),
        .library(name: "Countries", targets: ["Countries"]),
        .library(name: "InputField", targets: ["InputField"]),
        .library(name: "TestHelpers", targets: ["TestHelpers"]),
        .library(name: "ScanFeature", targets: ["ScanFeature"]),
        .library(name: "Permissions", targets: ["Permissions"]),
        .library(name: "MenuFeature", targets: ["MenuFeature"]),
        .library(name: "Integration", targets: ["Integration"]),
        .library(name: "ChatFeature", targets: ["ChatFeature"]),
        .library(name: "PushFeature", targets: ["PushFeature"]),
        .library(name: "SFTPFeature", targets: ["SFTPFeature"]),
        .library(name: "CrashService", targets: ["CrashService"]),
        .library(name: "Presentation", targets: ["Presentation"]),
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
        .library(name: "DependencyInjection", targets: ["DependencyInjection"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick", from: "3.0.0"),
        .package(url: "https://github.com/Quick/Nimble", from: "9.0.0"),
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.1"),
        .package(url: "https://github.com/icanzilb/Retry.git", from: "0.6.3"),
        .package(url: "https://github.com/ekazaev/ChatLayout", from: "1.1.14"),
        .package(url: "https://github.com/ra1028/DifferenceKit", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-protobuf", from: "1.14.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "6.1.0"),
        .package(url: "https://github.com/dropbox/SwiftyDropbox.git", from: "8.2.1"),
        .package(url: "https://github.com/amosavian/FileProvider.git", from: "0.26.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.9.5"),
        .package(url: "https://github.com/darrarski/ScrollViewController", from: "1.2.0"),
        .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "0.5.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.1"),
        .package(url: "https://github.com/google/google-api-objectivec-client-for-rest", from: "1.6.0"),
        .package(url: "https://git.xx.network/elixxir/client-ios-db.git", .upToNextMajor(from: "1.0.5")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "8.10.0")),
        .package(url: "https://github.com/darrarski/Shout.git", revision: "df5a662293f0ac15eeb4f2fd3ffd0c07b73d0de0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git",.upToNextMajor(from: "0.32.0")),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", .upToNextMajor(from: "0.5.0")),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git", .upToNextMajor(from: "0.3.3")),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                "Keychain",
                "Voxophone",
                "Permissions",
                "ScanFeature",
                "ChatFeature",
                "MenuFeature",
                "PushFeature",
                "SFTPFeature",
                "ToastFeature",
                "CrashService",
                "BackupFeature",
                "SearchFeature",
                "LaunchFeature",
                "iCloudFeature",
                "DropboxFeature",
                "ContactFeature",
                "RestoreFeature",
                "ProfileFeature",
                "CrashReporting",
                "ChatListFeature",
                "SettingsFeature",
                "RequestsFeature",
                "OnboardingFeature",
                "GoogleDriveFeature",
                "ContactListFeature"
            ]
        ),
        .target(name: "CrashReporting"),
        .target(name: "NetworkMonitor"),
        .target(name: "VersionChecking"),
        .target(name: "DependencyInjection"),
        .target(name: "InputField", dependencies: ["Shared"]),
        .binaryTarget(name: "Bindings", path: "XCFrameworks/Bindings.xcframework"),

        // MARK: - Permissions

            .target(
                name: "Permissions",
                dependencies: [
                    "Theme",
                    "Shared",
                    "DependencyInjection"
                ]
            ),

        // MARK: - PushFeature

            .target(
                name: "PushFeature",
                dependencies: [
                    "Models",
                    "Defaults",
                    "Integration",
                    "DependencyInjection"
                ]
            ),

        // MARK: - TestHelpers

            .target(
                name: "TestHelpers",
                dependencies: [
                    "Models",
                    "Presentation"
                ]
            ),

        // MARK: - Keychain

            .target(
                name: "Keychain",
                dependencies: [
                    .product(
                        name: "KeychainAccess",
                        package: "KeychainAccess"
                    )
                ]
            ),

        // MARK: - Voxophone

            .target(
                name: "Voxophone",
                dependencies: [
                    "Shared"
                ]
            ),

        // MARK: - Models

            .target(
                name: "Models",
                dependencies: [
                    .product(
                        name: "DifferenceKit",
                        package: "DifferenceKit"
                    ),
                    .product(
                        name: "SwiftProtobuf",
                        package: "swift-protobuf"
                    )
                ]
            ),

        // MARK: - Defaults

            .target(
                name: "Defaults",
                dependencies: [
                    "DependencyInjection"
                ]
            ),

        // MARK: - ToastFeature

            .target(
                name: "ToastFeature",
                dependencies: [
                    "Shared"
                ]
            ),

        // MARK: - CrashService

            .target(
                name: "CrashService",
                dependencies: [
                    "CrashReporting",
                    .product(
                        name: "FirebaseCrashlytics",
                        package: "firebase-ios-sdk"
                    )
                ]
            ),

        // MARK: - SFTPFeature

            .target(
                name: "SFTPFeature",
                dependencies: [
                    "HUD",
                    "Models",
                    "Shared",
                    "Keychain",
                    "InputField",
                    "DependencyInjection",
                    .product(
                        name: "Shout",
                        package: "Shout"
                    )
                ]
            ),

        // MARK: - GoogleDriveFeature

            .target(
                name: "GoogleDriveFeature",
                dependencies: [
                    .product(
                        name: "GoogleSignIn",
                        package: "GoogleSignIn-iOS"
                    ),
                    .product(
                        name: "GoogleAPIClientForREST_Drive",
                        package: "google-api-objectivec-client-for-rest"
                    )
                ],
                resources: [.process("Resources")]
            ),

        // MARK: - iCloudFeature

            .target(
                name: "iCloudFeature",
                dependencies: [
                    .product(
                        name: "FilesProvider",
                        package: "FileProvider"
                    )
                ]
            ),

        // MARK: - DropboxFeature

            .target(
                name: "DropboxFeature",
                dependencies: [
                    .product(
                        name: "SwiftyDropbox",
                        package: "SwiftyDropbox"
                    )
                ],
                resources: [.process("Resources")]
            ),

        // MARK: - Countries

            .target(
                name: "Countries",
                dependencies: [
                    "Theme",
                    "Shared",
                    "DependencyInjection"
                ],
                resources: [.process("Resources")]
            ),

        // MARK: - Theme

            .target(
                name: "Theme",
                dependencies: [
                    "Defaults",
                    "DependencyInjection"
                ]
            ),

        // MARK: - DrawerFeature

            .target(
                name: "DrawerFeature",
                dependencies: [
                    "Shared",
                    "InputField",
                    .product(
                        name: "ScrollViewController",
                        package: "ScrollViewController"
                    )
                ]
            ),

        // MARK: - HUD

            .target(
                name: "HUD",
                dependencies: [
                    "Theme",
                    "Shared",
                    .product(
                        name: "SnapKit",
                        package: "SnapKit"
                    )
                ]
            ),

        // MARK: - XXLogger

            .target(
                name: "XXLogger",
                dependencies: [
                    .product(
                        name: "SwiftyBeaver",
                        package: "SwiftyBeaver"
                    )
                ]
            ),

        // MARK: - Shared

            .target(
                name: "Shared",
                dependencies: [
                    .product(
                        name: "SnapKit",
                        package: "SnapKit"
                    ),
                    .product(
                        name: "ChatLayout",
                        package: "ChatLayout"
                    ),
                    .product(
                        name: "DifferenceKit",
                        package: "DifferenceKit"
                    )
                ],
                exclude: ["swiftgen.yml"],
                resources: [.process("Resources")]
            ),

        // MARK: - Integration

            .target(
                name: "Integration",
                dependencies: [
                    "Shared",
                    "Bindings",
                    "XXLogger",
                    "Keychain",
                    "ToastFeature",
                    "BackupFeature",
                    "CrashReporting",
                    "NetworkMonitor",
                    "DependencyInjection",
                    .product(
                        name: "Retry",
                        package: "Retry"
                    ),
                    .product(
                        name: "XXDatabase",
                        package: "client-ios-db"
                    ),
                    .product(
                        name: "XXLegacyDatabaseMigrator",
                        package: "client-ios-db"
                    )
                ],
                resources: [.process("Resources")]
            ),

        // MARK: - Presentation

            .target(
                name: "Presentation",
                dependencies: [
                    "Theme",
                    "Shared",
                    .product(
                        name: "SnapKit",
                        package: "SnapKit"
                    )
                ]
            ),

        // MARK: - ChatInputFeature

            .target(
                name: "ChatInputFeature",
                dependencies: [
                    "Voxophone",
                    .product(
                        name: "ComposableArchitecture",
                        package: "swift-composable-architecture"
                    )
                ]
            ),

        // MARK: - RestoreFeature

            .target(
                name: "RestoreFeature",
                dependencies: [
                    "HUD",
                    "Shared",
                    "SFTPFeature",
                    "Integration",
                    "Presentation",
                    "iCloudFeature",
                    "DropboxFeature",
                    "GoogleDriveFeature",
                    "DependencyInjection"
                ]
            ),

        // MARK: - ContactFeature

            .target(
                name: "ContactFeature",
                dependencies: [
                    "Shared",
                    "InputField",
                    "ChatFeature",
                    "Presentation",
                    .product(
                        name: "CombineSchedulers",
                        package: "combine-schedulers"
                    ),
                    .product(
                        name: "ScrollViewController",
                        package: "ScrollViewController"
                    )
                ]
            ),

        // MARK: - ChatFeature

            .target(
                name: "ChatFeature",
                dependencies: [
                    "HUD",
                    "Theme",
                    "Shared",
                    "Defaults",
                    "Keychain",
                    "Voxophone",
                    "Integration",
                    "Permissions",
                    "Presentation",
                    "DrawerFeature",
                    "ChatInputFeature",
                    "DependencyInjection",
                    .product(
                        name: "ChatLayout",
                        package: "ChatLayout"
                    ),
                    .product(
                        name: "DifferenceKit",
                        package: "DifferenceKit"
                    ),
                    .product(
                        name: "ScrollViewController",
                        package: "ScrollViewController"
                    )
                ]
            ),

        // MARK: - SearchFeature

            .target(
                name: "SearchFeature",
                dependencies: [
                    "HUD",
                    "Shared",
                    "Countries",
                    "Integration",
                    "Presentation",
                    "ContactFeature",
                    "DependencyInjection"
                ]
            ),

        // MARK: - LaunchFeature

            .target(
                name: "LaunchFeature",
                dependencies: [
                    "HUD",
                    "Theme",
                    "Shared",
                    "Defaults",
                    "PushFeature",
                    "Integration",
                    "Permissions",
                    "DropboxFeature",
                    "VersionChecking",
                    "DependencyInjection"
                ]
            ),

        // MARK: - RequestsFeature

            .target(
                name: "RequestsFeature",
                dependencies: [
                    "Theme",
                    "Shared",
                    "Integration",
                    "ToastFeature",
                    "ContactFeature",
                    "DependencyInjection",
                    .product(
                        name: "DifferenceKit",
                        package: "DifferenceKit"
                    )
                ]
            ),

        // MARK: - ProfileFeature

            .target(
                name: "ProfileFeature",
                dependencies: [
                    "HUD",
                    "Theme",
                    "Shared",
                    "Keychain",
                    "Defaults",
                    "Countries",
                    "InputField",
                    "MenuFeature",
                    "Permissions",
                    "Integration",
                    "Presentation",
                    "DrawerFeature",
                    "DependencyInjection",
                    .product(
                        name: "CombineSchedulers",
                        package: "combine-schedulers"
                    ),
                    .product(
                        name: "ScrollViewController",
                        package: "ScrollViewController"
                    )
                ]
            ),

        // MARK: - ChatListFeature

            .target(
                name: "ChatListFeature",
                dependencies: [
                    "Theme",
                    "Shared",
                    "Defaults",
                    "MenuFeature",
                    "ChatFeature",
                    "ProfileFeature",
                    "SettingsFeature",
                    "ContactListFeature",
                    "DependencyInjection",
                    .product(
                        name: "DifferenceKit",
                        package: "DifferenceKit"
                    )
                ]
            ),

        // MARK: - OnboardingFeature

            .target(
                name: "OnboardingFeature",
                dependencies: [
                    "HUD",
                    "Shared",
                    "Defaults",
                    "Keychain",
                    "Countries",
                    "InputField",
                    "Permissions",
                    "PushFeature",
                    "Integration",
                    "Presentation",
                    "DrawerFeature",
                    "VersionChecking",
                    "DependencyInjection",
                    .product(
                        name: "CombineSchedulers",
                        package: "combine-schedulers"
                    ),
                    .product(
                        name: "ScrollViewController",
                        package: "ScrollViewController"
                    )
                ]
            ),

        // MARK: - MenuFeature

            .target(
                name: "MenuFeature",
                dependencies: [
                    "Theme",
                    "Shared",
                    "Defaults",
                    "Integration",
                    "Presentation",
                    "DependencyInjection"
                ]
            ),

        // MARK: - BackupFeature

            .target(
                name: "BackupFeature",
                dependencies: [
                    "HUD",
                    "Shared",
                    "Models",
                    "InputField",
                    "SFTPFeature",
                    "Presentation",
                    "iCloudFeature",
                    "DrawerFeature",
                    "DropboxFeature",
                    "GoogleDriveFeature",
                    "DependencyInjection"
                ]
            ),

        // MARK: - ScanFeature

            .target(
                name: "ScanFeature",
                dependencies: [
                    "Theme",
                    "Shared",
                    "Countries",
                    "Permissions",
                    "Integration",
                    "Presentation",
                    "ContactFeature",
                    "DependencyInjection",
                    .product(
                        name: "SnapKit",
                        package: "SnapKit"
                    )
                ]
            ),

        // MARK: - ContactListFeature

            .target(
                name: "ContactListFeature",
                dependencies: [
                    "Theme",
                    "Shared",
                    "Integration",
                    "Presentation",
                    "ContactFeature",
                    "DependencyInjection",
                    .product(
                        name: "DifferenceKit",
                        package: "DifferenceKit"
                    )
                ]
            ),

        // MARK: - SettingsFeature

            .target(
                name: "SettingsFeature",
                dependencies: [
                    "HUD",
                    "Theme",
                    "Shared",
                    "Defaults",
                    "Keychain",
                    "InputField",
                    "PushFeature",
                    "Permissions",
                    "MenuFeature",
                    "Integration",
                    "Presentation",
                    "DrawerFeature",
                    "DependencyInjection",
                    .product(
                        name: "CombineSchedulers",
                        package: "combine-schedulers"
                    ),
                    .product(
                        name: "ScrollViewController",
                        package: "ScrollViewController"
                    )
                ]
            ),

        // MARK: - DependencyInjectionTests

            .testTarget(
                name: "DependencyInjectionTests",
                dependencies: ["DependencyInjection"]
            ),

        // MARK: - ProfileFeatureTests

            .testTarget(
                name: "ProfileFeatureTests",
                dependencies: [
                    "TestHelpers",
                    "ProfileFeature",
                    .product(name: "Quick", package: "Quick"),
                    .product(name: "Nimble", package: "Nimble")
                ]
            ),

        // MARK: - ContactFeatureTests

            .testTarget(
                name: "ContactFeatureTests",
                dependencies: [
                    "TestHelpers",
                    "ContactFeature",
                    .product(name: "Quick", package: "Quick"),
                    .product(name: "Nimble", package: "Nimble")
                ]
            ),

        // MARK: - SearchFeatureTests

            .testTarget(
                name: "SearchFeatureTests",
                dependencies: [
                    "TestHelpers",
                    "SearchFeature",
                    .product(name: "Quick", package: "Quick"),
                    .product(name: "Nimble", package: "Nimble")
                ]
            ),

        // MARK: - RequestsFeatureTests

            .testTarget(
                name: "RequestsFeatureTests",
                dependencies: [
                    "TestHelpers",
                    "RequestsFeature",
                    .product(name: "Quick", package: "Quick"),
                    .product(name: "Nimble", package: "Nimble")
                ]
            ),

        // MARK: - SettingsFeatureTests

            .testTarget(
                name: "SettingsFeatureTests",
                dependencies: [
                    "TestHelpers",
                    "SettingsFeature",
                    .product(name: "Quick", package: "Quick"),
                    .product(name: "Nimble", package: "Nimble")
                ]
            ),

        // MARK: - SettingsFeatureTests

            .testTarget(
                name: "ChatListFeatureTests",
                dependencies: [
                    "TestHelpers",
                    "ChatListFeature",
                    .product(name: "Quick", package: "Quick"),
                    .product(name: "Nimble", package: "Nimble")
                ]
            ),

        // MARK: - ContactListFeatureTests

            .testTarget(
                name: "ContactListFeatureTests",
                dependencies: [
                    "TestHelpers",
                    "ContactListFeature",
                    .product(name: "Quick", package: "Quick"),
                    .product(name: "Nimble", package: "Nimble")
                ]
            ),

        // MARK: - OnboardingFeatureTests

            .testTarget(
                name: "OnboardingFeatureTests",
                dependencies: [
                    "TestHelpers",
                    "OnboardingFeature",
                    .product(name: "Quick", package: "Quick"),
                    .product(name: "Nimble", package: "Nimble")
                ]
            ),

        // MARK: - PresentationTests

            .testTarget(
                name: "PresentationTests",
                dependencies: [
                    "Presentation",
                    .product(name: "Quick", package: "Quick"),
                    .product(name: "Nimble", package: "Nimble")
                ]
            ),

        // MARK: - ThemeTests

            .testTarget(
                name: "ThemeTests",
                dependencies: [
                    "Theme",
                    .product(name: "Quick", package: "Quick"),
                    .product(name: "Nimble", package: "Nimble")
                ]
            ),

        // MARK: - ChatFeatureTests

            .testTarget(
                name: "ChatFeatureTests",
                dependencies: [
                    "ChatFeature",
                    "TestHelpers",
                    .product(name: "Quick", package: "Quick"),
                    .product(name: "Nimble", package: "Nimble")
                ]
            ),

        // MARK: - ScanFeatureTests

            .testTarget(
                name: "ScanFeatureTests",
                dependencies: [
                    "TestHelpers",
                    "ScanFeature",
                    .product(name: "Quick", package: "Quick"),
                    .product(name: "Nimble", package: "Nimble")
                ]
            ),

        // MARK: - CollectionView

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
    ]
)
