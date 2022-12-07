// swift-tools-version:5.6
import PackageDescription

let swiftSettings: [SwiftSetting] = [
  //.unsafeFlags(["-Xfrontend", "-warn-concurrency"]),
  // .unsafeFlags(["-Xfrontend", "-debug-time-function-bodies"]),
  // .unsafeFlags(["-Xfrontend", "-debug-time-expression-type-checking"]),
]

let package = Package(
  name: "client-ios",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(name: "Shared", targets: ["Shared"]),
    .library(name: "AppCore", targets: ["AppCore"]),
    .library(name: "Defaults", targets: ["Defaults"]),
    .library(name: "Keychain", targets: ["Keychain"]),
    .library(name: "Voxophone", targets: ["Voxophone"]),
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "InputField", targets: ["InputField"]),
    .library(name: "ScanFeature", targets: ["ScanFeature"]),
    .library(name: "MenuFeature", targets: ["MenuFeature"]),
    .library(name: "ChatFeature", targets: ["ChatFeature"]),
    .library(name: "CrashReport", targets: ["CrashReport"]),
    .library(name: "UpdateErrors", targets: ["UpdateErrors"]),
    .library(name: "CheckVersion", targets: ["CheckVersion"]),
    .library(name: "AppResources", targets: ["AppResources"]),
    .library(name: "TermsFeature", targets: ["TermsFeature"]),
    .library(name: "AppNavigation", targets: ["AppNavigation"]),
    .library(name: "BackupFeature", targets: ["BackupFeature"]),
    .library(name: "LaunchFeature", targets: ["LaunchFeature"]),
    .library(name: "SearchFeature", targets: ["SearchFeature"]),
    .library(name: "DrawerFeature", targets: ["DrawerFeature"]),
    .library(name: "WebsiteFeature", targets: ["WebsiteFeature"]),
    .library(name: "RestoreFeature", targets: ["RestoreFeature"]),
    .library(name: "ProfileFeature", targets: ["ProfileFeature"]),
    .library(name: "ContactFeature", targets: ["ContactFeature"]),
    .library(name: "FetchBannedList", targets: ["FetchBannedList"]),
    .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
    .library(name: "ChatListFeature", targets: ["ChatListFeature"]),
    .library(name: "RequestsFeature", targets: ["RequestsFeature"]),
    .library(name: "ReportingFeature", targets: ["ReportingFeature"]),
    .library(name: "ChatInputFeature", targets: ["ChatInputFeature"]),
    .library(name: "GroupDraftFeature", targets: ["GroupDraftFeature"]),
    .library(name: "ProcessBannedList", targets: ["ProcessBannedList"]),
    .library(name: "OnboardingFeature", targets: ["OnboardingFeature"]),
    .library(name: "CreateGroupFeature", targets: ["CreateGroupFeature"]),
    .library(name: "CountryListFeature", targets: ["CountryListFeature"]),
    .library(name: "PermissionsFeature", targets: ["PermissionsFeature"]),
    .library(name: "ContactListFeature", targets: ["ContactListFeature"]),
    .library(name: "RequestPermissionFeature", targets: ["RequestPermissionFeature"]),
    .library(name: "HUDFeature", targets: ["HUDFeature"]),
  ],
  dependencies: [
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
      url: "https://git.xx.network/elixxir/elixxir-dapps-sdk-swift",
      .upToNextMajor(from: "1.0.0")
    ),
    .package(
      url: "https://git.xx.network/elixxir/client-ios-db.git",
      .upToNextMajor(from: "1.1.0")
    ),
    .package(
      url: "https://git.xx.network/elixxir/xxm-cloud-providers.git",
      .upToNextMajor(from: "1.0.2")
    ),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk.git",
      .upToNextMajor(from: "8.10.0")
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      .upToNextMajor(from: "0.43.0")
    ),
    .package(
      url: "https://github.com/swiftcsv/SwiftCSV.git",
      from: "0.8.0"
    ),
    .package(
      url: "https://github.com/apple/swift-log.git",
      .upToNextMajor(from: "1.4.4")
    ),
    .package(
      url: "https://github.com/kean/Pulse.git",
      .upToNextMajor(from: "2.1.3")
    ),
    .package(
      url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git",
      .upToNextMajor(from: "0.3.3")
    ),
  ],
  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        .target(name: "AppCore"),
        .target(name: "Keychain"),
        .target(name: "ScanFeature"),
        .target(name: "ChatFeature"),
        .target(name: "MenuFeature"),
        .target(name: "CrashReport"),
        .target(name: "TermsFeature"),
        .target(name: "BackupFeature"),
        .target(name: "SearchFeature"),
        .target(name: "LaunchFeature"),
        .target(name: "ContactFeature"),
        .target(name: "WebsiteFeature"),
        .target(name: "RestoreFeature"),
        .target(name: "ProfileFeature"),
        .target(name: "ChatListFeature"),
        .target(name: "SettingsFeature"),
        .target(name: "RequestsFeature"),
        .target(name: "ReportingFeature"),
        .target(name: "GroupDraftFeature"),
        .target(name: "OnboardingFeature"),
        .target(name: "CreateGroupFeature"),
        .target(name: "ContactListFeature"),
        .target(name: "RequestPermissionFeature"),
        .product(name: "PulseUI", package: "Pulse"), // TO REMOVE
        .product(name: "PulseLogHandler", package: "Pulse"), // TO REMOVE
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "AppFeatureTests",
      dependencies: [
        .target(name: "AppFeature"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "AppCore",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "AppResources"),
        .product(name: "SnapKit", package: "SnapKit"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "XXModels", package: "client-ios-db"),
        .product(name: "XXDatabase", package: "client-ios-db"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "CheckVersion",
      dependencies: [
        .product(
          name: "Dependencies",
          package: "swift-composable-architecture"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "Voxophone",
      dependencies: [
        .target(name: "Shared"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "WebsiteFeature",
      swiftSettings: swiftSettings
    ),
    .target(
      name: "CrashReport",
      dependencies: [
        .product(
          name: "FirebaseCrashlytics",
          package: "firebase-ios-sdk"
        ),
        .product(
          name: "Dependencies",
          package: "swift-composable-architecture"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "AppNavigation",
      dependencies: [
        .product(
          name: "XXModels",
          package: "client-ios-db"
        ),
        .product(
          name: "Dependencies",
          package: "swift-composable-architecture"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "CreateGroupFeature",
      dependencies: [
        .target(name: "AppCore")
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "GroupDraftFeature",
      dependencies: [
        .target(name: "AppCore")
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "PermissionsFeature",
      dependencies: [
        .product(
          name: "XCTestDynamicOverlay",
          package: "xctest-dynamic-overlay"
        ),
        .product(
          name: "Dependencies",
          package: "swift-composable-architecture"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "AppResources",
      exclude: [
        "swiftgen.yml",
      ],
      resources: [
        .process("Resources")
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "InputField",
      dependencies: [
        .target(name: "Shared"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "RequestPermissionFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "AppCore"),
        .target(name: "AppResources"),
        .target(name: "AppNavigation"),
        .target(name: "PermissionsFeature"),
        .product(
          name: "Dependencies",
          package: "swift-composable-architecture"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "Keychain",
      dependencies: [
        .product(
          name: "KeychainAccess",
          package: "KeychainAccess"
        ),
        .product(
          name: "Dependencies",
          package: "swift-composable-architecture"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "Defaults",
      dependencies: [
        .product(
          name: "Dependencies",
          package: "swift-composable-architecture"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "CountryListFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "AppCore")
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "DrawerFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "InputField"),
        .product(name: "ScrollViewController", package: "ScrollViewController"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "Shared",
      dependencies: [
        .product(name: "SnapKit", package: "SnapKit"),
        .product(name: "ChatLayout", package: "ChatLayout"),
        .product(name: "DifferenceKit", package: "DifferenceKit"),
        .product(name: "SwiftProtobuf", package: "swift-protobuf"),
      ],
      resources: [
        .process("Resources"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "ChatInputFeature",
      dependencies: [
        .target(
          name: "Voxophone"
        ),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "RestoreFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "AppCore"),
        .product(name: "XXDatabase", package: "client-ios-db"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "CloudFilesDrive", package: "xxm-cloud-providers"),
        .product(name: "CloudFilesDropbox", package: "xxm-cloud-providers"),
        .product(name: "CloudFilesSFTP", package: "xxm-cloud-providers"),
        .product(name: "CloudFilesICloud", package: "xxm-cloud-providers"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "ContactFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "InputField"),
        .target(name: "ChatFeature"),
        .product(name: "CombineSchedulers", package: "combine-schedulers"),
        .product(name: "ScrollViewController", package: "ScrollViewController"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "ChatFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "AppCore"),
        .target(name: "Defaults"),
        .target(name: "Keychain"),
        .target(name: "Voxophone"),
        .target(name: "DrawerFeature"),
        .target(name: "ChatInputFeature"),
        .target(name: "ReportingFeature"),
        .target(name: "RequestPermissionFeature"),
        .product(name: "ChatLayout", package: "ChatLayout"),
        .product(name: "DifferenceKit", package: "DifferenceKit"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "ScrollViewController", package: "ScrollViewController"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "SearchFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "ContactFeature"),
        .target(name: "CountryListFeature"),
        .product(name: "Retry", package: "Retry"),
        .product(name: "XXDatabase", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "LaunchFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "Defaults"),
        .target(name: "UpdateErrors"),
        .target(name: "CheckVersion"),
        .target(name: "BackupFeature"),
        .target(name: "FetchBannedList"),
        .target(name: "ReportingFeature"),
        .target(name: "ProcessBannedList"),
        .target(name: "RequestPermissionFeature"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "CloudFilesSFTP", package: "xxm-cloud-providers"),
        .product(name: "CombineSchedulers", package: "combine-schedulers"),
        .product(name: "CloudFilesDropbox", package: "xxm-cloud-providers"),
        .product(name: "XXLegacyDatabaseMigrator", package: "client-ios-db"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "TermsFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "Defaults"),
        .target(name: "AppNavigation"),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "UpdateErrors",
      dependencies: [
        .product(
          name: "XXClient",
          package: "elixxir-dapps-sdk-swift"
        ),
        .product(
          name: "XCTestDynamicOverlay",
          package: "xctest-dynamic-overlay"
        ),
        .product(
          name: "Dependencies",
          package: "swift-composable-architecture"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "ProcessBannedList",
      dependencies: [
        .product(
          name: "SwiftCSV",
          package: "SwiftCSV"
        ),
        .product(
          name: "XCTestDynamicOverlay",
          package: "xctest-dynamic-overlay"
        ),
        .product(
          name: "Dependencies",
          package: "swift-composable-architecture"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "FetchBannedList",
      dependencies: [
        .product(
          name: "XCTestDynamicOverlay",
          package: "xctest-dynamic-overlay"
        ),
        .product(
          name: "Dependencies",
          package: "swift-composable-architecture"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "RequestsFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "ContactFeature"),
        .product(
          name: "DifferenceKit",
          package: "DifferenceKit"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "ProfileFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "Keychain"),
        .target(name: "Defaults"),
        .target(name: "InputField"),
        .target(name: "MenuFeature"),
        .target(name: "DrawerFeature"),
        .target(name: "BackupFeature"),
        .target(name: "CountryListFeature"),
        .target(name: "RequestPermissionFeature"),
        .product(name: "CombineSchedulers", package: "combine-schedulers"),
        .product(name: "ScrollViewController", package: "ScrollViewController"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "ChatListFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "Defaults"),
        .target(name: "MenuFeature"),
        .target(name: "ChatFeature"),
        .target(name: "ProfileFeature"),
        .target(name: "SettingsFeature"),
        .target(name: "ContactListFeature"),
        .product(name: "DifferenceKit", package: "DifferenceKit"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "OnboardingFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "AppCore"),
        .target(name: "Defaults"),
        .target(name: "Keychain"),
        .target(name: "InputField"),
        .target(name: "DrawerFeature"),
        .target(name: "AppNavigation"),
        .target(name: "CountryListFeature"),
        .target(name: "RequestPermissionFeature"),
        .product(name: "CombineSchedulers", package: "combine-schedulers"),
        .product(name: "ScrollViewController", package: "ScrollViewController"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "MenuFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "AppCore"),
        .target(name: "Defaults"),
        .target(name: "DrawerFeature"),
        .target(name: "ReportingFeature"),
        .product(
          name: "XXClient",
          package: "elixxir-dapps-sdk-swift"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "BackupFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "AppCore"),
        .target(name: "InputField"),
        .target(name: "DrawerFeature"),
        .product(
          name: "XXClient",
          package: "elixxir-dapps-sdk-swift"
        ),
        .product(
          name: "CloudFilesSFTP",
          package: "xxm-cloud-providers"
        ),
        .product(
          name: "CloudFilesDrive",
          package: "xxm-cloud-providers"
        ),
        .product(
          name: "CloudFilesICloud",
          package: "xxm-cloud-providers"
        ),
        .product(
          name: "CloudFilesDropbox",
          package: "xxm-cloud-providers"
        ),
        .product(
          name: "XXMessengerClient",
          package: "elixxir-dapps-sdk-swift"
        ),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "ScanFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "ContactFeature"),
        .target(name: "CountryListFeature"),
        .target(name: "RequestPermissionFeature"),
        .product(name: "SnapKit", package: "SnapKit"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "ContactListFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "ContactFeature"),
        .product(name: "DifferenceKit", package: "DifferenceKit"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "SettingsFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "Defaults"),
        .target(name: "Keychain"),
        .target(name: "InputField"),
        .target(name: "MenuFeature"),
        .target(name: "CrashReport"),
        .target(name: "DrawerFeature"),
        .target(name: "RequestPermissionFeature"),
        .product(name: "CombineSchedulers", package: "combine-schedulers"),
        .product(name: "ScrollViewController", package: "ScrollViewController"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "ReportingFeature",
      dependencies: [
        .target(name: "DrawerFeature"),
        .target(name: "Shared"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ],
      resources: [
        .process("Resources"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "HUDFeature",
      dependencies: [
        .target(name: "AppResources"),
        .target(name: "Shared"),
        .product(name: "Dependencies", package: "swift-composable-architecture"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ],
      swiftSettings: swiftSettings
    ),
  ]
)
