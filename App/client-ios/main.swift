import UIKit
import AppFeature

let appDelegate: String? =
    NSClassFromString("XCTestCase") == nil
        ? NSStringFromClass(AppDelegate.self)
        : nil

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, appDelegate)
