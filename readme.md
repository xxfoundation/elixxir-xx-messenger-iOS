![swift 5.0](https://img.shields.io/badge/swift-5.0-blue)
![platform iOS](https://img.shields.io/badge/platform-iOS-blue)

# xx messenger
- Build number: Σ commits (Check App/set_build_number.sh)

## How to setup
Clone the project and run. If you'd like to run the project without using the xx network, run the `Mock` scheme. Otherwise, run the `Release` scheme. Since the project is written in Swift 5.0, it requires Xcode 10.2 minimum.

## Dependencies
- App features and external dependencies are defined on `Package.swift`
- xx network framework dependency is stored inside the `XCFrameworks` directory and it's added as a `binaryTarget`.

## Architecture
- MVVM+C

## Tooling and 3rd parties
- [GRDB] (https://github.com/groue/GRDB.swift)
- [Retry] (https://github.com/icanzilb/Retry.git)
- [SnapKit] (https://github.com/SnapKit/SnapKit)
- [SwiftGen] (https://github.com/SwiftGen/SwiftGen)
- [Fastlane] (https://github.com/fastlane/fastlane)
- [Firebase] (https://github.com/firebase/firebase-ios-sdk.git)
- [ChatLayout] (https://github.com/ekazaev/ChatLayout)
- [SwiftyBeaver] (https://github.com/SwiftyBeaver/SwiftyBeaver.git)
- [SwiftProtobuf] (https://github.com/apple/swift-protobuf)
- [DifferenceKit] (https://github.com/ra1028/DifferenceKit)
- [KeychainAccess] (https://github.com/kishikawakatsumi/KeychainAccess)
- [CombineSchedulers] (https://github.com/pointfreeco/combine-schedulers)
- [ScrollViewController] (https://github.com/darrarski/ScrollViewController)
- [TheComposableArchitecture] (https://github.com/pointfreeco/swift-composable-architecture.git)

For testing:
- [Quick] (https://github.com/Quick/Quick)
- [Nimble] (https://github.com/Quick/Nimble)

## Important note: 
Compiling and building this on your own will prevent you from getting automatic updates through AppStore. Updating the app manually could break the app and you could lose your username in order to do a fresh install to use the app again. Backup support (coming soon) will allow the preservation of accounts.
