// swift-tools-version:5.6
import PackageDescription

// MARK: - Helpers

struct Feature {
    var product: Product
    var targets: [Target]
    var targetDependency: Target.Dependency

    static func library(
        name: String,
        dependencies: [Target.Dependency] = [],
        testDependencies: [Target.Dependency] = [],
        swiftSettings: [SwiftSetting] = [
            .unsafeFlags(
                [
                    "-Xfrontend",
                    "-debug-time-function-bodies",
                    "-Xfrontend",
                    "-debug-time-expression-type-checking",
                ],
                .when(configuration: .debug)
            )
        ]
    ) -> Feature {
        .init(
            product: .library(name: name, targets: [name]),
            targets: [
                .target(
                    name: name,
                    dependencies: dependencies,
                    swiftSettings: swiftSettings
                ),
                .testTarget(
                    name: "\(name)Tests",
                    dependencies: [.target(name: name)] + testDependencies,
                    swiftSettings: swiftSettings
                ),
            ],
            targetDependency: .target(name: name)
        )
    }
}

struct Dependency {
    var packageDependency: Package.Dependency
    var targetDependency: Target.Dependency

    static func local(
        path: String,
        name: String,
        package: String
    ) -> Dependency {
        .init(
            packageDependency: .package(path: path),
            targetDependency: .product(name: name, package: package)
        )
    }

    static func external(
        url: String,
        version: Range<Version>,
        name: String,
        package: String
    ) -> Dependency {
        .init(
            packageDependency: .package(url: url, version),
            targetDependency: .product(name: name, package: package)
        )
    }
}

// MARK: - Manifest

extension Dependency {
    static let all: [Dependency] = [
        .retry,
        .quick,
        .shout,
        .nimble,
        .snapkit,
        .firebase,
        .chatLayout,
        .googleDrive,
        .googleSignIn,
        .fileProvider,
        .swiftyBeaver,
        .swiftyDropbox,
        .differenceKit,
        .swiftProtobuf,
        .clientDatabase,
        .keychainAccess,
        .swiftCustomDump,
        .combineSchedulers,
        .xcTestDynamicOverlay,
        .scrollViewController,
        .composableArchitecture
    ]

    static let keychainAccess = Dependency.external(
        url: "https://github.com/kishikawakatsumi/KeychainAccess.git",
        version: .upToNextMajor(from: "4.2.2"),
        name: "KeychainAccess",
        package: "KeychainAccess"
    )

    static let combineSchedulers = Dependency.external(
        url: "https://github.com/pointfreeco/combine-schedulers",
        version: .upToNextMajor(from: "0.5.0"),
        name: "CombineSchedulers",
        package: "CombineSchedulers"
    )

    static let quick = Dependency.external(
        url: "https://github.com/Quick/Quick",
        version: .upToNextMajor(from: "3.0.0"),
        name: "Quick",
        package: "Quick"
    )

    static let nimble = Dependency.external(
        url: "https://github.com/Quick/Nimble",
        version: .upToNextMajor(from: "9.0.0"),
        name: "Nimble",
        package: "Nimble"
    )

    static let snapkit = Dependency.external(
        url: "https://github.com/SnapKit/SnapKit",
        version: .upToNextMajor(from: "5.0.1"),
        name: "SnapKit",
        package: "SnapKit"
    )

    static let retry = Dependency.external(
        url: "https://github.com/icanzilb/Retry.git",
        version: .upToNextMajor(from: "0.6.3"),
        name: "Retry",
        package: "Retry"
    )

    static let chatLayout = Dependency.external(
        url: "https://github.com/ekazaev/ChatLayout",
        version: .upToNextMajor(from: "1.1.14"),
        name: "ChatLayout",
        package: "ChatLayout"
    )

    static let differenceKit = Dependency.external(
        url: "https://github.com/ra1028/DifferenceKit",
        version: .upToNextMajor(from: "1.2.0"),
        name: "DifferenceKit",
        package: "DifferenceKit"
    )

    static let swiftProtobuf = Dependency.external(
        url: "https://github.com/apple/swift-protobuf",
        version: .upToNextMajor(from: "1.14.0"),
        name: "SwiftProtobuf",
        package: "SwiftProtobuf"
    )

    static let googleSignIn = Dependency.external(
        url: "https://github.com/google/GoogleSignIn-iOS",
        version: .upToNextMajor(from: "6.1.0"),
        name: "GoogleSignIn-iOS",
        package: "GoogleSignIn-iOS"
    )

    static let swiftyDropbox = Dependency.external(
        url: "https://github.com/dropbox/SwiftyDropbox.git",
        version: .upToNextMajor(from: "8.2.1"),
        name: "SwiftyDropbox",
        package: "SwiftyDropbox"
    )

    static let fileProvider = Dependency.external(
        url: "https://github.com/amosavian/FileProvider.git",
        version: .upToNextMajor(from: "0.26.0"),
        name: "FileProvider",
        package: "FileProvider"
    )

    static let swiftyBeaver = Dependency.external(
        url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git",
        version: .upToNextMajor(from: "1.9.5"),
        name: "SwiftyBeaver",
        package: "SwiftyBeaver"
    )

    static let scrollViewController = Dependency.external(
        url: "https://github.com/darrarski/ScrollViewController",
        version: .upToNextMajor(from: "1.2.0"),
        name: "ScrollViewController",
        package: "ScrollViewController"
    )

    static let swiftCustomDump = Dependency.external(
        url: "https://github.com/pointfreeco/swift-custom-dump.git",
        version: .upToNextMajor(from: "0.5.0"),
        name: "SwiftCustomDump",
        package: "SwiftCustomDump"
    )

    static let xcTestDynamicOverlay = Dependency.external(
        url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git",
        version: .upToNextMajor(from: "0.3.3"),
        name: "XCTestDynamicOverlay",
        package: "xctest-dynamic-overlay"
    )

    static let composableArchitecture = Dependency.external(
        url: "https://github.com/pointfreeco/swift-composable-architecture.git",
        version: .upToNextMajor(from: "0.32.0"),
        name: "ComposableArchitecture",
        package: "swift-composable-architecture"
    )

    static let shout = Dependency.external(
        url: "https://github.com/darrarski/Shout.git",
        version: .upToNextMajor(from: ""), // revision: df5a662293f0ac15eeb4f2fd3ffd0c07b73d0de0
        name: "Shout",
        package: "Shout"
    )

    static let firebase = Dependency.external(
        url: "https://github.com/firebase/firebase-ios-sdk.git",
        version: .upToNextMajor(from: "8.10.0"),
        name: "Firebase",
        package: "Firebase"
    )

    static let clientDatabase = Dependency.external(
        url: "https://git.xx.network/elixxir/client-ios-db.git",
        version: .upToNextMajor(from: "1.0.8"),
        name: "",
        package: ""
    )

    static let googleDrive = Dependency.external(
        url: "https://github.com/google/google-api-objectivec-client-for-rest",
        version: .upToNextMajor(from: "1.6.0"),
        name: "GoogleDrive",
        package: "GoogleDrive"
    )
}

extension Feature {
    static let all: [Feature] = [
        .app
    ]

    static let app = Feature.library(
        name: "App",
        dependencies: [
            Feature.scan.targetDependency,
            Feature.chat.targetDependency,
            Feature.menu.targetDependency,
            Feature.push.targetDependency,
            Feature.sftp.targetDependency,
            Feature.drive.targetDependency,
            Feature.toast.targetDependency,
            Feature.backup.targetDependency,
            Feature.search.targetDependency,
            Feature.launch.targetDependency,
            Feature.icloud.targetDependency,
            Feature.dropbox.targetDependency,
            Feature.contact.targetDependency,
            Feature.restore.targetDependency,
            Feature.profile.targetDependency,
            Feature.chatList.targetDependency,
            Feature.settings.targetDependency,
            Feature.requests.targetDependency,
            Feature.keychain.targetDependency,
            Feature.voxophone.targetDependency,
            Feature.onboarding.targetDependency,
            Feature.permissions.targetDependency,
            Feature.contactList.targetDependency,
            Feature.crashReporting.targetDependency
        ]
    )

    static let permissions = Feature.library(
        name: "Permissions",
        dependencies: [
            Feature.theme.targetDependency,
            Feature.shared.targetDependency,
            Feature.dependencyInjection.targetDependency
        ]
    )

    static let crashReporting = Feature.library(
        name: "CrashReporting"
    )

    static let networkMonitor = Feature.library(
        name: "NetworkMonitor"
    )

    static let versionChecking = Feature.library(
        name: "VersionChecking"
    )

    static let dependencyInjection = Feature.library(
        name: "DependencyInjection"
    )

    static let inputField = Feature.library(
        name: "InputField",
        dependencies: [
            Feature.shared.targetDependency
        ]
    )

    static let push = Feature.library(
        name: "PushFeature",
        dependencies: [
            Feature.models.targetDependency,
            Feature.defaults.targetDependency,
            Feature.integration.targetDependency,
            Feature.dependencyInjection.targetDependency
        ]
    )

    static let testHelpers = Feature.library(
        name: "TestHelpers",
        dependencies: [
            Feature.models.targetDependency,
            Feature.presentation.targetDependency
        ]
    )

    static let keychain = Feature.library(
        name: "Keychain",
        dependencies: [
            Dependency.keychainAccess.targetDependency
        ]
    )

    static let voxophone = Feature.library(
        name: "Voxophone",
        dependencies: [
            Feature.shared.targetDependency
        ]
    )

    static let models = Feature.library(
        name: "Models",
        dependencies: [
            Dependency.differenceKit.targetDependency,
            Dependency.swiftProtobuf.targetDependency
        ]
    )

    static let defaults = Feature.library(
        name: "Defaults",
        dependencies: [
            Feature.dependencyInjection.targetDependency
        ]
    )

    static let toast = Feature.library(
        name: "ToastFeature",
        dependencies: [
            Feature.shared.targetDependency
        ]
    )

    static let crashService = Feature.library(
        name: "CrashService",
        dependencies: [
            Dependency.firebase.targetDependency,
            Feature.crashReporting.targetDependency
        ]
    )

    static let sftp = Feature.library(
        name: "SFTPFeature",
        dependencies: [
            Feature.hud.targetDependency,
            Feature.models.targetDependency,
            Feature.shared.targetDependency,
            Dependency.shout.targetDependency,
            Feature.keychain.targetDependency,
            Feature.inputField.targetDependency,
            Feature.presentation.targetDependency,
            Feature.dependencyInjection.targetDependency
        ]
    )

    static let drive = library(
        name: "GoogleDriveFeature",
        dependencies: [
            Dependency.googleDrive.targetDependency,
            Dependency.googleSignIn.targetDependency
        ] // resources: [.process("Resources")]
    )

    static let icloud = library(
        name: "iCloudFeature",
        dependencies: [
            Dependency.fileProvider.targetDependency
        ]
    )

    static let dropbox = library(
        name: "DropboxFeature",
        dependencies: [
            Dependency.swiftyDropbox.targetDependency
        ] // resources: [.process("Resources")]
    )

    static let countries = library(
        name: "Countries",
        dependencies: [
            Feature.theme.targetDependency,
            Feature.shared.targetDependency,
            Feature.dependencyInjection.targetDependency,
        ] // resources: [.process("Resources")]
    )

    static let theme = library(
        name: "Theme",
        dependencies: [
            Feature.defaults.targetDependency,
            Feature.dependencyInjection.targetDependency
        ]
    )

    static let drawer = library(
        name: "DrawerFeature",
        dependencies: [
            Feature.shared.targetDependency,
            Feature.inputField.targetDependency,
            Dependency.scrollViewController.targetDependency
        ]
    )

    static let hud = library(
        name: "HUD",
        dependencies: [
            Feature.theme.targetDependency,
            Feature.shared.targetDependency,
            Dependency.snapkit.targetDependency
        ]
    )

    static let logger = library(
        name: "XXLogger",
        dependencies: [
            Dependency.swiftyBeaver.targetDependency
        ]
    )

    static let shared = library(
        name: "Shared",
        dependencies: [
            Dependency.snapkit.targetDependency,
            Dependency.chatLayout.targetDependency,
            Dependency.differenceKit.targetDependency,
        ] // resources: [.process("Resources")] + exclude: ["swiftgen.yml"],
    )

    static let integration = library(
        name: "Integration",
        dependencies: [
            Feature.shared.targetDependency,
            Feature.bindings.targetDependency,
            Feature.logger.targetDependency,
            Feature.keychain.targetDependency,
            Feature.toast.targetDependency,
            Feature.backup.targetDependency,
            Feature.crashReporting.targetDependency,
            Feature.networkMonitor.targetDependency,
            Feature.dependencyInjection.targetDependency,
            Dependency.retry.targetDependency,
            Dependency.clientDatabase.targetDependency
            // resources: [.process("Resources")]
            // Dependency.clientDatabase.targetDependency <--- XXLegacyDatabaseMigrator
        ]
    )

    static let presentation = library(
        name: "Presentation",
        dependencies: [
            Feature.theme.targetDependency,
            Feature.shared.targetDependency,
            Dependency.snapkit.targetDependency
        ]
    )

    static let chatInput = library(
        name: "ChatInputFeature",
        dependencies: [
            Feature.voxophone.targetDependency,
            Dependency.composableArchitecture.targetDependency
        ]
    )

    static let restore = library(
        name: "RestoreFeature",
        dependencies: [
            Feature.hud.targetDependency,
            Feature.shared.targetDependency,
            Feature.sftp.targetDependency,
            Feature.integration.targetDependency,
            Feature.presentation.targetDependency,
            Feature.icloud.targetDependency,
            Feature.dropbox.targetDependency,
            Feature.drive.targetDependency,
            Feature.dependencyInjection.targetDependency
        ]
    )

    static let contact = library(
        name: "ContactFeature",
        dependencies: [
            Feature.shared.targetDependency,
            Feature.inputField.targetDependency,
            Feature.chat.targetDependency,
            Feature.presentation.targetDependency,
            Dependency.combineSchedulers.targetDependency,
            Dependency.scrollViewController.targetDependency
        ]
    )

    static let chat = library(
        name: "ChatFeature",
        dependencies: [
            Feature.hud.targetDependency,
            Feature.theme.targetDependency,
            Feature.shared.targetDependency,
            Feature.defaults.targetDependency,
            Feature.keychain.targetDependency,
            Feature.voxophone.targetDependency,
            Feature.integration.targetDependency,
            Feature.permissions.targetDependency,
            Feature.presentation.targetDependency,
            Feature.drawer.targetDependency,
            Feature.chatInput.targetDependency,
            Feature.dependencyInjection.targetDependency,
            Dependency.chatLayout.targetDependency,
            Dependency.differenceKit.targetDependency,
            Dependency.scrollViewController.targetDependency
        ]
    )

    static let search = library(
        name: "SearchFeature",
        dependencies: [
            Feature.hud.targetDependency,
            Feature.shared.targetDependency,
            Feature.countries.targetDependency,
            Feature.integration.targetDependency,
            Feature.presentation.targetDependency,
            Feature.contact.targetDependency,
            Feature.dependencyInjection.targetDependency
        ]
    )

    static let launch = library(
        name: "LaunchFeature",
        dependencies: [
            Feature.hud.targetDependency,
            Feature.theme.targetDependency,
            Feature.shared.targetDependency,
            Feature.defaults.targetDependency,
            Feature.push.targetDependency,
            Feature.integration.targetDependency,
            Feature.permissions.targetDependency,
            Feature.dropbox.targetDependency,
            Feature.versionChecking.targetDependency,
            Feature.dependencyInjection.targetDependency
        ]
    )

    static let requests = library(
        name: "RequestsFeature",
        dependencies: [
            Feature.theme.targetDependency,
            Feature.shared.targetDependency,
            Feature.integration.targetDependency,
            Feature.toast.targetDependency,
            Feature.contact.targetDependency,
            Feature.dependencyInjection.targetDependency,
            Dependency.differenceKit.targetDependency
        ]
    )

    static let profile = library(
        name: "ProfileFeature",
        dependencies: [
            Feature.hud.targetDependency,
            Feature.theme.targetDependency,
            Feature.shared.targetDependency,
            Feature.keychain.targetDependency,
            Feature.defaults.targetDependency,
            Feature.countries.targetDependency,
            Feature.inputField.targetDependency,
            Feature.menu.targetDependency,
            Feature.permissions.targetDependency,
            Feature.integration.targetDependency,
            Feature.presentation.targetDependency,
            Feature.drawer.targetDependency,
            Feature.dependencyInjection.targetDependency,
            Dependency.combineSchedulers.targetDependency,
            Dependency.scrollViewController.targetDependency
        ]
    )

    static let chatList = library(
        name: "ChatListFeature",
        dependencies: [
            Feature.theme.targetDependency,
            Feature.shared.targetDependency,
            Feature.defaults.targetDependency,
            Feature.menu.targetDependency,
            Feature.chat.targetDependency,
            Feature.profile.targetDependency,
            Feature.settings.targetDependency,
            Feature.contactList.targetDependency,
            Feature.dependencyInjection.targetDependency,
            Dependency.differenceKit.targetDependency
        ]
    )

    static let onboarding = library(
        name: "OnboardingFeature",
        dependencies: [
            Feature.hud.targetDependency,
            Feature.shared.targetDependency,
            Feature.defaults.targetDependency,
            Feature.keychain.targetDependency,
            Feature.countries.targetDependency,
            Feature.inputField.targetDependency,
            Feature.permissions.targetDependency,
            Feature.push.targetDependency,
            Feature.integration.targetDependency,
            Feature.presentation.targetDependency,
            Feature.drawer.targetDependency,
            Feature.versionChecking.targetDependency,
            Feature.dependencyInjection.targetDependency,
            Dependency.combineSchedulers.targetDependency,
            Dependency.scrollViewController.targetDependency
        ]
    )

    static let menu = library(
        name: "MenuFeature",
        dependencies: [
            Feature.theme.targetDependency,
            Feature.shared.targetDependency,
            Feature.defaults.targetDependency,
            Feature.integration.targetDependency,
            Feature.presentation.targetDependency,
            Feature.dependencyInjection.targetDependency
        ]
    )

    static let backup = library(
        name: "BackupFeature",
        dependencies: [
            Feature.hud.targetDependency,
            Feature.shared.targetDependency,
            Feature.models.targetDependency,
            Feature.inputField.targetDependency,
            Feature.sftp.targetDependency,
            Feature.presentation.targetDependency,
            Feature.icloud.targetDependency,
            Feature.drawer.targetDependency,
            Feature.dropbox.targetDependency,
            Feature.drive.targetDependency,
            Feature.dependencyInjection.targetDependency
        ]
    )

    static let scan = library(
        name: "ScanFeature",
        dependencies: [
            Feature.theme.targetDependency,
            Feature.shared.targetDependency,
            Feature.countries.targetDependency,
            Feature.permissions.targetDependency,
            Feature.integration.targetDependency,
            Feature.presentation.targetDependency,
            Feature.contact.targetDependency,
            Feature.dependencyInjection.targetDependency,
            Dependency.snapkit.targetDependency
        ]
    )

    static let contactList = library(
        name: "ContactListFeature",
        dependencies: [
            Feature.theme.targetDependency,
            Feature.shared.targetDependency,
            Feature.integration.targetDependency,
            Feature.presentation.targetDependency,
            Feature.contact.targetDependency,
            Feature.dependencyInjection.targetDependency,
            Dependency.differenceKit.targetDependency
        ]
    )

    static let settings = library(
        name: "SettingsFeature",
        dependencies: [
            Feature.hud.targetDependency,
            Feature.theme.targetDependency,
            Feature.shared.targetDependency,
            Feature.defaults.targetDependency,
            Feature.keychain.targetDependency,
            Feature.inputField.targetDependency,
            Feature.push.targetDependency,
            Feature.permissions.targetDependency,
            Feature.menu.targetDependency,
            Feature.integration.targetDependency,
            Feature.presentation.targetDependency,
            Feature.drawer.targetDependency,
            Feature.dependencyInjection.targetDependency,
            Dependency.combineSchedulers.targetDependency,
            Dependency.scrollViewController.targetDependency
        ]
    )
}

let package = Package(
    name: "client-ios",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: Feature.all.map(\.product),
    dependencies: Dependency.all.map(\.packageDependency),
    targets: Feature.all.flatMap(\.targets)
)

//        // MARK: - DependencyInjectionTests
//
//            .testTarget(
//                name: "DependencyInjectionTests",
//                dependencies: ["DependencyInjection"]
//            ),
//
//        // MARK: - AppTests
//
//            .testTarget(
//                name: "AppTests",
//                dependencies: ["App"]
//            ),
//
//        // MARK: - ProfileFeatureTests
//
//            .testTarget(
//                name: "ProfileFeatureTests",
//                dependencies: [
//                    "TestHelpers",
//                    "ProfileFeature",
//                    .product(name: "Quick", package: "Quick"),
//                    .product(name: "Nimble", package: "Nimble")
//                ]
//            ),
//
//        // MARK: - ContactFeatureTests
//
//            .testTarget(
//                name: "ContactFeatureTests",
//                dependencies: [
//                    "TestHelpers",
//                    "ContactFeature",
//                    .product(name: "Quick", package: "Quick"),
//                    .product(name: "Nimble", package: "Nimble")
//                ]
//            ),
//
//        // MARK: - SearchFeatureTests
//
//            .testTarget(
//                name: "SearchFeatureTests",
//                dependencies: [
//                    "TestHelpers",
//                    "SearchFeature",
//                    .product(name: "Quick", package: "Quick"),
//                    .product(name: "Nimble", package: "Nimble")
//                ]
//            ),
//
//        // MARK: - RequestsFeatureTests
//
//            .testTarget(
//                name: "RequestsFeatureTests",
//                dependencies: [
//                    "TestHelpers",
//                    "RequestsFeature",
//                    .product(name: "Quick", package: "Quick"),
//                    .product(name: "Nimble", package: "Nimble")
//                ]
//            ),
//
//        // MARK: - SettingsFeatureTests
//
//            .testTarget(
//                name: "SettingsFeatureTests",
//                dependencies: [
//                    "TestHelpers",
//                    "SettingsFeature",
//                    .product(name: "Quick", package: "Quick"),
//                    .product(name: "Nimble", package: "Nimble")
//                ]
//            ),
//
//        // MARK: - SettingsFeatureTests
//
//            .testTarget(
//                name: "ChatListFeatureTests",
//                dependencies: [
//                    "TestHelpers",
//                    "ChatListFeature",
//                    .product(name: "Quick", package: "Quick"),
//                    .product(name: "Nimble", package: "Nimble")
//                ]
//            ),
//
//        // MARK: - ContactListFeatureTests
//
//            .testTarget(
//                name: "ContactListFeatureTests",
//                dependencies: [
//                    "TestHelpers",
//                    "ContactListFeature",
//                    .product(name: "Quick", package: "Quick"),
//                    .product(name: "Nimble", package: "Nimble")
//                ]
//            ),
//
//        // MARK: - OnboardingFeatureTests
//
//            .testTarget(
//                name: "OnboardingFeatureTests",
//                dependencies: [
//                    "TestHelpers",
//                    "OnboardingFeature",
//                    .product(name: "Quick", package: "Quick"),
//                    .product(name: "Nimble", package: "Nimble")
//                ]
//            ),
//
//        // MARK: - PresentationTests
//
//            .testTarget(
//                name: "PresentationTests",
//                dependencies: [
//                    "Presentation",
//                    .product(name: "Quick", package: "Quick"),
//                    .product(name: "Nimble", package: "Nimble")
//                ]
//            ),
//
//        // MARK: - ThemeTests
//
//            .testTarget(
//                name: "ThemeTests",
//                dependencies: [
//                    "Theme",
//                    .product(name: "Quick", package: "Quick"),
//                    .product(name: "Nimble", package: "Nimble")
//                ]
//            ),
//
//        // MARK: - ChatFeatureTests
//
//            .testTarget(
//                name: "ChatFeatureTests",
//                dependencies: [
//                    "ChatFeature",
//                    "TestHelpers",
//                    .product(name: "Quick", package: "Quick"),
//                    .product(name: "Nimble", package: "Nimble")
//                ]
//            ),
//
//        // MARK: - ScanFeatureTests
//
//            .testTarget(
//                name: "ScanFeatureTests",
//                dependencies: [
//                    "TestHelpers",
//                    "ScanFeature",
//                    .product(name: "Quick", package: "Quick"),
//                    .product(name: "Nimble", package: "Nimble")
//                ]
//            ),
//
//        // MARK: - CollectionView
//
//            .target(
//                name: "CollectionView",
//                dependencies: [
//                    .product(name: "ChatLayout", package: "ChatLayout"),
//                    .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
//                ]
//            ),
//            .testTarget(
//                name: "CollectionViewTests",
//                dependencies: [
//                    .target(name: "CollectionView"),
//                    .product(name: "CustomDump", package: "swift-custom-dump"),
//                ]
//            ),
//    ]
//)
