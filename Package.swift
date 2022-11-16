// swift-tools-version:5.6
import PackageDescription

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
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "InputField", targets: ["InputField"]),
    .library(name: "ScanFeature", targets: ["ScanFeature"]),
    .library(name: "MenuFeature", targets: ["MenuFeature"]),
    .library(name: "ChatFeature", targets: ["ChatFeature"]),
    .library(name: "PushFeature", targets: ["PushFeature"]),
    .library(name: "AppResources", targets: ["AppResources"]),
    .library(name: "CrashService", targets: ["CrashService"]),
    .library(name: "TermsFeature", targets: ["TermsFeature"]),
    .library(name: "BackupFeature", targets: ["BackupFeature"]),
    .library(name: "LaunchFeature", targets: ["LaunchFeature"]),
    .library(name: "SearchFeature", targets: ["SearchFeature"]),
    .library(name: "DrawerFeature", targets: ["DrawerFeature"]),
    .library(name: "RestoreFeature", targets: ["RestoreFeature"]),
    .library(name: "CrashReporting", targets: ["CrashReporting"]),
    .library(name: "ProfileFeature", targets: ["ProfileFeature"]),
    .library(name: "ContactFeature", targets: ["ContactFeature"]),
    .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
    .library(name: "ChatListFeature", targets: ["ChatListFeature"]),
    .library(name: "RequestsFeature", targets: ["RequestsFeature"]),
    .library(name: "ReportingFeature", targets: ["ReportingFeature"]),
    .library(name: "StatusBarFeature", targets: ["StatusBarFeature"]),
    .library(name: "ChatInputFeature", targets: ["ChatInputFeature"]),
    .library(name: "OnboardingFeature", targets: ["OnboardingFeature"]),
    .library(name: "CountryListFeature", targets: ["CountryListFeature"]),
    .library(name: "PermissionsFeature", targets: ["PermissionsFeature"]),
    .library(name: "ContactListFeature", targets: ["ContactListFeature"]),
    .library(name: "RequestPermissionFeature", targets: ["RequestPermissionFeature"]),
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
      path: "../elixxir-dapps-sdk-swift"
      //url: "https://git.xx.network/elixxir/elixxir-dapps-sdk-swift",
      //branch: "development"
    ),
    .package(
      path: "../xxm-cloud-providers"
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
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      .upToNextMajor(from: "0.43.0")
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
      url: "https://github.com/apple/swift-log.git",
      .upToNextMajor(from: "1.4.4")
    ),
    .package(
      url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git",
      .upToNextMajor(from: "0.3.3")
    ),
    .package(
      path: "../xxm-navigation"
    ),
    .package(
      url: "https://git.xx.network/elixxir/xxm-di",
      .upToNextMajor(from: "1.0.0")
    )
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
        .target(name: "PushFeature"),
        .target(name: "TermsFeature"),
        .target(name: "CrashService"),
        .target(name: "BackupFeature"),
        .target(name: "SearchFeature"),
        .target(name: "LaunchFeature"),
        .target(name: "ContactFeature"),
        .target(name: "RestoreFeature"),
        .target(name: "ProfileFeature"),
        .target(name: "CrashReporting"),
        .target(name: "ChatListFeature"),
        .target(name: "SettingsFeature"),
        .target(name: "RequestsFeature"),
        .target(name: "ReportingFeature"),
        .target(name: "OnboardingFeature"),
        .target(name: "ContactListFeature"),
        .target(name: "RequestPermissionFeature"),
        .product(name: "DependencyInjection", package: "xxm-di"),
      ]
    ),
    .testTarget(
      name: "AppFeatureTests",
      dependencies: [
        .target(name: "AppFeature"),
      ]
    ),
    .target(
      name: "AppCore",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "AppResources"),
        .target(name: "StatusBarFeature"),
        .product(name: "SnapKit", package: "SnapKit"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "XXModels", package: "client-ios-db"),
        .product(name: "XXDatabase", package: "client-ios-db"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "CrashReporting"
    ),
    .target(
      name: "PermissionsFeature",
      dependencies: [
        .product(
          name: "XCTestDynamicOverlay",
          package: "xctest-dynamic-overlay"
        ),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
      ]
    ),
    .target(
      name: "StatusBarFeature",
      dependencies: [
        .product(
          name: "XCTestDynamicOverlay",
          package: "xctest-dynamic-overlay"
        ),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
      ]
    ),
    .target(
      name: "AppResources",
      resources: [
        .process("Resources")
      ]
    ),
    .target(
      name: "InputField",
      dependencies: [
        .target(name: "Shared"),
      ]
    ),
    .target(
      name: "RequestPermissionFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "AppResources"),
        .target(name: "PermissionsFeature"),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
      ]
    ),
    .target(
      name: "PushFeature",
      dependencies: [
        .target(name: "Defaults"),
        .target(name: "ReportingFeature"),
        .product(name: "DependencyInjection", package: "xxm-di"),
        .product(name: "XXDatabase", package: "client-ios-db"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
      ]
    ),
    .target(
      name: "Keychain",
      dependencies: [
        .product(name: "KeychainAccess", package: "KeychainAccess"),
      ]
    ),
    .target(
      name: "Defaults",
      dependencies: [
        .product(name: "DependencyInjection", package: "xxm-di"),
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
      name: "CountryListFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "StatusBarFeature")
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
      name: "Shared",
      dependencies: [
        .product(name: "SnapKit", package: "SnapKit"),
        .product(name: "ChatLayout", package: "ChatLayout"),
        .product(name: "DifferenceKit", package: "DifferenceKit"),
        .product(name: "SwiftProtobuf", package: "swift-protobuf"),
      ],
      exclude: [
        "swiftgen.yml",
      ],
      resources: [
        .process("Resources"),
      ]
    ),
    .target(
      name: "ChatInputFeature",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
      ]
    ),
    .target(
      name: "RestoreFeature",
      dependencies: [
        .target(name: "Shared"),
        .product(name: "XXDatabase", package: "client-ios-db"),
        .product(name: "Navigation", package: "xxm-navigation"),
        .product(name: "DependencyInjection", package: "xxm-di"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "CloudFilesDrive", package: "xxm-cloud-providers"),
        .product(name: "CloudFilesDropbox", package: "xxm-cloud-providers"),
        .product(name: "CloudFilesSFTP", package: "xxm-cloud-providers"),
        .product(name: "CloudFilesICloud", package: "xxm-cloud-providers"),
      ]
    ),
    .target(
      name: "ContactFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "InputField"),
        .target(name: "ChatFeature"),
        .product(name: "CombineSchedulers", package: "combine-schedulers"),
        .product(name: "ScrollViewController", package: "ScrollViewController"),
      ]
    ),
    .target(
      name: "ChatFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "Defaults"),
        .target(name: "Keychain"),
        .target(name: "DrawerFeature"),
        .target(name: "ChatInputFeature"),
        .target(name: "ReportingFeature"),
        .target(name: "RequestPermissionFeature"),
        .product(name: "DependencyInjection", package: "xxm-di"),
        .product(name: "ChatLayout", package: "ChatLayout"),
        .product(name: "DifferenceKit", package: "DifferenceKit"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "ScrollViewController", package: "ScrollViewController"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "SearchFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "PushFeature"),
        .target(name: "ContactFeature"),
        .target(name: "CountryListFeature"),
        .product(name: "Retry", package: "Retry"),
        .product(name: "XXDatabase", package: "client-ios-db"),
        .product(name: "DependencyInjection", package: "xxm-di"),
      ]
    ),
    .target(
      name: "LaunchFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "Defaults"),
        .target(name: "PushFeature"),
        .target(name: "BackupFeature"),
        .target(name: "ReportingFeature"),
        .target(name: "RequestPermissionFeature"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "CloudFilesSFTP", package: "xxm-cloud-providers"),
        .product(name: "CombineSchedulers", package: "combine-schedulers"),
        .product(name: "CloudFilesDropbox", package: "xxm-cloud-providers"),
        .product(name: "XXLegacyDatabaseMigrator", package: "client-ios-db"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
      ]
    ),
    .target(
      name: "TermsFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "Defaults"),
        .product(name: "Navigation", package: "xxm-navigation"),
      ]
    ),
    .target(
      name: "RequestsFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "ContactFeature"),
        .product(name: "DependencyInjection", package: "xxm-di"),
        .product(name: "DifferenceKit", package: "DifferenceKit"),
      ]
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
        .product(name: "Navigation", package: "xxm-navigation"),
        .product(name: "DependencyInjection", package: "xxm-di"),
        .product(name: "CombineSchedulers", package: "combine-schedulers"),
        .product(name: "ScrollViewController", package: "ScrollViewController"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
      ]
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
        .product(name: "DependencyInjection", package: "xxm-di"),
        .product(name: "DifferenceKit", package: "DifferenceKit"),
      ]
    ),
    .target(
      name: "OnboardingFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "AppCore"),
        .target(name: "Defaults"),
        .target(name: "Keychain"),
        .target(name: "InputField"),
        .target(name: "PushFeature"),
        .target(name: "DrawerFeature"),
        .target(name: "CountryListFeature"),
        .target(name: "RequestPermissionFeature"),
        .product(name: "CombineSchedulers", package: "combine-schedulers"),
        .product(name: "ScrollViewController", package: "ScrollViewController"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "MenuFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "Defaults"),
        .target(name: "DrawerFeature"),
        .target(name: "ReportingFeature"),
        .product(name: "Navigation", package: "xxm-navigation"),
        .product(name: "DependencyInjection", package: "xxm-di"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
      ]
    ),
    .target(
      name: "BackupFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "AppCore"),
        .target(name: "InputField"),
        .target(name: "DrawerFeature"),
        .product(
          name: "Navigation",
          package: "xxm-navigation"
        ),
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
      ]
    ),
    .target(
      name: "ScanFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "ContactFeature"),
        .target(name: "CountryListFeature"),
        .target(name: "RequestPermissionFeature"),
        .product(name: "DependencyInjection", package: "xxm-di"),
        .product(name: "SnapKit", package: "SnapKit"),
      ]
    ),
    .target(
      name: "ContactListFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "ContactFeature"),
        .product(name: "DependencyInjection", package: "xxm-di"),
        .product(name: "DifferenceKit", package: "DifferenceKit"),
      ]
    ),
    .target(
      name: "SettingsFeature",
      dependencies: [
        .target(name: "Shared"),
        .target(name: "Defaults"),
        .target(name: "Keychain"),
        .target(name: "InputField"),
        .target(name: "PushFeature"),
        .target(name: "MenuFeature"),
        .target(name: "DrawerFeature"),
        .target(name: "RequestPermissionFeature"),
        .product(name: "DependencyInjection", package: "xxm-di"),
        .product(name: "CombineSchedulers", package: "combine-schedulers"),
        .product(name: "ScrollViewController", package: "ScrollViewController"),
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
