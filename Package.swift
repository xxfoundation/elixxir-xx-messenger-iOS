// swift-tools-version:5.3
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
        .library(name: "Popup", targets: ["Popup"]),
        .library(name: "Shared", targets: ["Shared"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "XXLogger", targets: ["XXLogger"]),
        .library(name: "Database", targets: ["Database"]),
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
        .library(name: "CrashService", targets: ["CrashService"]),
        .library(name: "Presentation", targets: ["Presentation"]),
        .library(name: "SearchFeature", targets: ["SearchFeature"]),
        .library(name: "CrashReporting", targets: ["CrashReporting"]),
        .library(name: "ProfileFeature", targets: ["ProfileFeature"]),
        .library(name: "ContactFeature", targets: ["ContactFeature"]),
        .library(name: "NetworkMonitor", targets: ["NetworkMonitor"]),
        .library(name: "VersionChecking", targets: ["VersionChecking"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        .library(name: "ChatListFeature", targets: ["ChatListFeature"]),
        .library(name: "RequestsFeature", targets: ["RequestsFeature"]),
        .library(name: "ChatInputFeature", targets: ["ChatInputFeature"]),
        .library(name: "PushNotifications", targets: ["PushNotifications"]),
        .library(name: "OnboardingFeature", targets: ["OnboardingFeature"]),
        .library(name: "ContactListFeature", targets: ["ContactListFeature"]),
        .library(name: "DependencyInjection", targets: ["DependencyInjection"])
    ],
    dependencies: [
        .package(
            name: "Quick",
            url: "https://github.com/Quick/Quick",
            from: "3.0.0"
        ),
        .package(
            name: "DifferenceKit",
            url: "https://github.com/ra1028/DifferenceKit",
            from: "1.2.0"
        ),
        .package(
            name: "Nimble",
            url: "https://github.com/Quick/Nimble",
            from: "9.0.0"
        ),
        .package(
            name: "GRDB",
            url: "https://github.com/groue/GRDB.swift",
            from: "5.3.0"
        ),
        .package(
            name: "SnapKit",
            url: "https://github.com/SnapKit/SnapKit",
            from: "5.0.1"
        ),
        .package(
            name: "Firebase",
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "8.10.0")
        ),
        .package(
            name: "SwiftProtobuf",
            url: "https://github.com/apple/swift-protobuf",
            from: "1.14.0"
        ),
        .package(
            name: "KeychainAccess",
            url: "https://github.com/kishikawakatsumi/KeychainAccess",
            from: "4.2.1"
        ),
        .package(
            name: "Retry",
            url: "https://github.com/icanzilb/Retry.git",
            from: "0.6.3"
        ),
        .package(
            name: "ChatLayout",
            url: "https://github.com/ekazaev/ChatLayout",
            from: "1.1.14"
        ),
        .package(
            name: "SwiftyBeaver",
            url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git",
            from: "1.9.5"
        ),
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            .upToNextMajor(from: "0.32.0")
        ),
        .package(
            name: "ScrollViewController",
            url: "https://github.com/darrarski/ScrollViewController",
            from: "1.2.0"
        ),
        .package(
            name: "combine-schedulers",
            url: "https://github.com/pointfreeco/combine-schedulers",
            from: "0.5.0"
        )
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
                "CrashService",
                "SearchFeature",
                "ContactFeature",
                "ProfileFeature",
                "CrashReporting",
                "ChatListFeature",
                "SettingsFeature",
                "PushNotifications",
                "OnboardingFeature",
                "ContactListFeature"
            ]
        ),
        .target(name: "CrashReporting"),
        .target(name: "NetworkMonitor"),
        .target(name: "VersionChecking"),
        .target(name: "DependencyInjection"),
        .target(name: "InputField", dependencies: ["Shared"]),
        .binaryTarget(name: "Bindings", path: "XCFrameworks/Bindings.xcframework"),

        // MARK: - PushNotifications

            .target(
                name: "Permissions",
                dependencies: [
                    "Theme",
                    "Shared",
                    "DependencyInjection"
                ]
            ),

            .target(
                name: "PushNotifications",
                dependencies: [
                    "XXLogger",
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
                        package: "SwiftProtobuf"
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

        // MARK: - CrashService

            .target(
                name: "CrashService",
                dependencies: [
                    "CrashReporting",
                    .product(
                        name: "FirebaseCrashlytics",
                        package: "Firebase"
                    )
                ]
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

        // MARK: - Popup

            .target(
                name: "Popup",
                dependencies: [
                    "Shared",
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

        // MARK: - Database

            .target(
                name: "Database",
                dependencies: [
                    "Models",
                    "XXLogger",
                    .product(
                        name: "GRDB",
                        package: "GRDB"
                    ),
                    .product(
                        name: "DifferenceKit",
                        package: "DifferenceKit"
                    )
                ]
            ),

        // MARK: - Shared

            .target(
                name: "Shared",
                dependencies: [
                    .product(
                        name: "DifferenceKit",
                        package: "DifferenceKit"
                    ),
                    .product(
                        name: "ChatLayout",
                        package: "ChatLayout"
                    ),
                    .product(
                        name: "SnapKit",
                        package: "SnapKit"
                    )
                ],
                exclude: ["swiftgen.yml"],
                resources: [.process("Resources")]
            ),

        // MARK: - Integration

            .target(
                name: "Integration",
                dependencies: [
                    "XXLogger",
                    "Shared",
                    "Database",
                    "Bindings",
                    "CrashReporting",
                    "NetworkMonitor",
                    "DependencyInjection",
                    .product(
                        name: "Retry",
                        package: "Retry"
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

        // MARK: - ContactFeature

            .target(
                name: "ContactFeature",
                dependencies: [
                    "Shared",
                    "InputField",
                    "ChatFeature",
                    "Presentation",
                    .product(
                        name: "ScrollViewController",
                        package: "ScrollViewController"
                    ),
                    .product(
                        name: "CombineSchedulers",
                        package: "combine-schedulers"
                    )
                ]
            ),

        // MARK: - ChatFeature

            .target(
                name: "ChatFeature",
                dependencies: [
                    "HUD",
                    "Theme",
                    "Popup",
                    "Shared",
                    "Defaults",
                    "Keychain",
                    "Integration",
                    "ChatInputFeature",
                    "Permissions",
                    "Voxophone",
                    "Presentation",
                    "DependencyInjection",
                    .product(
                        name: "DifferenceKit",
                        package: "DifferenceKit"
                    ),
                    .product(
                        name: "ChatLayout",
                        package: "ChatLayout"
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

        // MARK: - RequestsFeature

            .target(
                name: "RequestsFeature",
                dependencies: [
                    "Theme",
                    "Shared",
                    "Integration",
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
                    "Popup",
                    "Shared",
                    "Keychain",
                    "Defaults",
                    "Countries",
                    "InputField",
                    "Permissions",
                    "Integration",
                    "Presentation",
                    "DependencyInjection",
                    .product(
                        name: "ScrollViewController",
                        package: "ScrollViewController"
                    ),
                    .product(
                        name: "CombineSchedulers",
                        package: "combine-schedulers"
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
                    "Popup",
                    "Shared",
                    "Defaults",
                    "Keychain",
                    "Countries",
                    "InputField",
                    "Permissions",
                    "Integration",
                    "Presentation",
                    "VersionChecking",
                    "PushNotifications",
                    "DependencyInjection",
                    .product(
                        name: "ScrollViewController",
                        package: "ScrollViewController"
                    ),
                    .product(
                        name: "CombineSchedulers",
                        package: "combine-schedulers"
                    )
                ]
            ),

        // MARK: - MenuFeature

            .target(
                name: "MenuFeature",
                dependencies: [
                    "Defaults",
                    "Presentation",
                    "ProfileFeature",
                    "RequestsFeature",
                    "SettingsFeature",
                    "ContactListFeature"
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
                    "Popup",
                    "Shared",
                    "Defaults",
                    "Keychain",
                    "InputField",
                    "Permissions",
                    "Integration",
                    "Presentation",
                    "PushNotifications",
                    "DependencyInjection",
                    .product(
                        name: "ScrollViewController",
                        package: "ScrollViewController"
                    ),
                    .product(
                        name: "CombineSchedulers",
                        package: "combine-schedulers"
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
            )
    ]
)
